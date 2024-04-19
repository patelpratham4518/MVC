public class WebinarCreation {
    public WebinarCreation(){}
    
    @InvocableMethod
    public static void createEvent(List<webinar__c> webinar){
        webinar w = new webinar();
        w.Id = webinar[0].Id;
        w.webinartime = webinar[0].WebinarTime__c;
        if(webinar[0].Subject__c != null){
            w.Subject = webinar[0].Subject__c;
        }else{
            w.Subject = '';
        }
        if(webinar[0].Description__c != null){
            w.Description = webinar[0].Description__c;
        }else{
            w.Description = '';
        }
        createEventFuture(JSON.serialize(w));
    }
    
    @future(callout=true)
    public static void createEventFuture(String webinar){
        webinar s1 = (webinar) JSON.deserialize(webinar, webinar.class);
        DateTime selectDate = s1.WebinarTime;
        
        // Info
        String consumerKey='324608710349-ks2ad5hkvac907dr7e9d1kjauagknm0u.apps.googleusercontent.com';
        String clientSecret='6y19vu1lCPTwbe4PYV-jafrj'; 
        
        String googleoAuthUrl='https://accounts.google.com/o/oauth2/auth?'; 
        String redirect_uri = 'https://dharmikmv-dev-ed--c.ap4.visual.force.com/apex/GoogleCalenderoAuth';
        String calendar_Scope = 'https://www.googleapis.com/auth/calendar';
        
        String accessToken = '';
        String errorMessage = '';
        
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        httpReq.setEndpoint('https://www.googleapis.com/oauth2/v4/token');
        httpReq.setMethod('POST');
        httpReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        List<GoogleCalenderInfo__c> googleSettingInfoList = new List<GoogleCalenderInfo__c>();
        googleSettingInfoList = GoogleCalenderInfo__c.getAll().values();
        String refreshToken;
        if(googleSettingInfoList.size() > 0 )
            refreshToken = googleSettingInfoList[0].Refresh_Token__c;
        
        System.debug('#### refreshToken '+refreshToken);
        String refreshTokenBody = 'client_id='+consumerKey+'&client_secret='+clientSecret+'&refresh_token='+refreshToken
            +'&grant_type=refresh_token';
        System.debug('#### refreshTokenBody '+refreshTokenBody);
        
        httpReq.setBody(refreshTokenBody);
        
        try{
            httpRes = http.send(httpReq); 
            if(httpRes.getStatusCode() == 200){
                Map<String,object> TokenInfo = (Map<String,object>)JSON.deserializeUntyped(httpRes.getBody());
                
                accessToken = String.valueOf(TokenInfo.get('access_token'));
            }else{
                errorMessage = 'Unexpected Error while communicating with Google Calendar API. '
                    +'Status '+httpRes.getStatus()+' and Status Code '+httpRes.getStatuscode();
                System.debug('Error ' + errorMessage);
            }
        }catch(System.Exception e){
            
            System.debug('#### Exception Executed '+e.getStackTraceString() + ' '+e.getMessage());
            if(String.valueOf(e.getMessage()).startsWith('Unauthorized endpoint')){
                errorMessage = 'Unauthorize endpoint: An Administer must go to Setup -> Administer -> Security Control ->'
                    +' Remote Site Setting and add '+' '+ 'https://www.googleapis.com/oauth2/v4/token' +' Endpoint';
            }else{
                errorMessage = 'Unexpected Error while communicating with Google Calendar API. '
                    +'Status '+httpRes.getStatus()+' and Status Code '+httpRes.getStatuscode();
            }
        }
        
        
        String DateForStart = selectDate.year()+'-'+selectDate.month()+'-'+selectDate.day() + 'T' + selectDate.hour() + ':' + selectDate.minute() + ':00' ;
        
        DateTime TimeEnd = selectDate;        
        TimeEnd = selectDate.addMinutes(60);
        
        String DateForEnd = selectDate.year()+'-'+selectDate.month()+'-'+selectDate.day() + 'T' + TimeEnd.hour() + ':' + TimeEnd.minute() + ':00' ;
        
        
        String requestBody = '{'+
            '"end": {'+
            '"dateTime": "'+DateForEnd+'",'+
            '"timeZone": "Asia/Kolkata"'+
            '},'+
            '"start": {'+
            '"dateTime": "'+DateForStart+'",'+
            '"timeZone": "Asia/Kolkata"'+
            '},'+
            '"kind": "calendar#event",'+
            '"summary": "'+s1.Subject+'",'+
            '"reminders":{"useDefault": false,"overrides":[{"method":"email","minutes":55}]},'+
            '"conferenceData": {"createRequest": {"requestId": "aaa-bbbb-vv"}},'+
            '"guestsCanSeeOtherGuests":"false",'+
            '"guestsCanModify":"false",'+
            '"guestsCanInviteOthers":"false",'+
            '"anyoneCanAddSelf":"false",'+
            '"description":"'+s1.Description+'"}';
        
        System.debug('#### requestBody '+requestBody); 
        Http httpRq = new Http(); 
        HttpRequest httpRequest = new HttpRequest();
        HttpResponse HttpResponse = new HttpResponse();
        
        httpRequest.setEndpoint('https://www.googleapis.com/calendar/v3/calendars/info@mvclouds.com/events/?sendNotifications=true&supportsAttachments=true&conferenceDataVersion=1');
        httpRequest.setMethod('POST');
        httpRequest.setBody(requestBody);
        httpRequest.setHeader('Content-Type', 'application/json'); 
        httpRequest.setHeader('Authorization','Bearer '+accessToken);
        
        try{
            HttpResponse = httpRq.send(httpRequest);
            if(HttpResponse.getStatusCode() == 200){       
                String strJSON = HttpResponse.getBody();
                System.debug(strJSON);
                List<Data> s = (List<Data>) JSON.deserialize('['+strJSON+']', List<Data>.class);
                System.debug(s);
                webinar__c w = new webinar__c();
                w.Id = s1.Id;                
                w.Google_Event_Id__c = s[0].Id;
                w.Meeting_Id__c = s[0].hangoutLink;
                update w;
            }else if(HttpResponse.getStatusCode() == 401){
                String errorMessage1 = 'Please refresh access token';
            }
            else{
                String errorMessage1 = 'Unexpected Error while communicating with Google Calendar API. '
                    +'Status '+HttpResponse.getStatus()+' and Status Code '+HttpResponse.getStatuscode();
            }
        }catch(System.Exception e){
            System.debug('#### Exception Executed : '+e.getMessage() + '  '+e.getStackTraceString() + ' '+e.getLineNumber());
        }
    }
    
    public class Data {
        @AuraEnabled public String id;
        @AuraEnabled public String hangoutLink;
    }
    
    public class webinar{
        public String id;
        public DateTime WebinarTime;
        public String Subject;
        public String Description;
    }
}