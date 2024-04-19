public without sharing class AutoLeadHandler  {
    
    public AutoLeadHandler(){
        string apexpagesgettingid= apexpages.currentpage().getparameters().get('id');
        webinarAttendee__c  web =[SELECT Id, Calendar_event__c, webinarlLead__r.email, webinar__r.WebinarTime__c,webinar__r.Meeting_Id__c,webinar__r.Id,webinar__r.Google_Event_Id__c FROM webinarAttendee__c WHERE Id =: apexpagesgettingid];
        DateTime myDate = web.webinar__r.WebinarTime__c;
        string subject = 'MV Clouds Salesforce Webinar';
        string iId = web.webinar__r.Id; 
        string gId = web.webinar__r.Google_Event_Id__c; 
        string meeting = web.webinar__r.Meeting_Id__c;
        
        
    }
    public void CheckBox(){
        string apexpagesgettingid= 'a096F00002aXQXE';
        webinarAttendee__c  web =[SELECT Id, Calendar_event__c FROM webinarAttendee__c WHERE Id =: apexpagesgettingid];
        web.Calendar_event__c = true;
        update web;
        
    }
    
    @InvocableMethod
    public static void createEvent(list<webinar__c> webinar){
        webinar w = new webinar();
        w.Id = webinar[0].Id;
        w.webinartime = webinar[0].WebinarTime__c;        
        createEventFuture(JSON.serialize(w));
    }
    
    @future(callout=true)
    public static void createEventFuture(String webinar){
        System.debug(webinar);
        webinar s1 = (webinar) JSON.deserialize(webinar, webinar.class);
        string subject = 'MV Clouds Salesforce Webinar';
        
        DateTime selectDate = s1.WebinarTime;
        //  Time selectTime;
        String iId;
        // String consumerKey='15485663049-lvl2vl416emj8ovasiuqdgjv8de4u86r.apps.googleusercontent.com';
        // String clientSecret='25G2q99Y9DiTC81wx14WBQRI';
        
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
        TimeEnd = selectDate.addMinutes(30);
        
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
            '"summary": "'+subject+'",'+
            '"reminders":{"useDefault": false,"overrides":[{"method":"email","minutes":55}]},'+
            '"conferenceData": {"createRequest": {"requestId": "aaa-bbbb-vv"}},'+
            '"description":""}';
        
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
    public class getIds {
        @AuraEnabled public String hangoutLink;
    }
    public class webinar{
        public String id;
        public DateTime WebinarTime;        
    }
    
}