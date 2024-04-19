public class AutoUpdateEvent {
    @InvocableMethod
    public static void UpEvent(List<webinarAttendee__c> webAt){
        System.debug(webAt);
        Set<Id> webIds = new Set<Id>();
        
        //List<webinarAttendee__c> webAt = [SELECT Id, webinar__c, webinarlLead__c, Calendar_event__c FROM webinarAttendee__c Where webinarlLead__c IN: ids];        
        for(webinarAttendee__c web : webAt){
            webIds.add(web.webinar__c);
        }        
        Webinar__c webnar = [Select Id,Name,Meeting_Id__c,WebinarTime__c,Google_Event_Id__c from Webinar__c Where ID IN: webIds Limit 1];
        
        string subject = webnar.Name;
        string iId = webnar.Id; 
        string meeting = webnar.Meeting_Id__c;    
        string gId = webnar.Google_Event_Id__c; 
        String LeadIn = '';
        
        for(webinarAttendee__c web : [SELECT Id, webinar__c, webinarlLead__c, webinarlLead__r.Email, Calendar_event__c FROM webinarAttendee__c Where webinar__c =: webnar.Id]){
            LeadIn += '{"email":"'+web.webinarlLead__r.Email+'"},';
		}
        LeadIn = LeadIn.removeEnd(',');       
        updateEvent(subject,iId ,gId ,meeting,LeadIn);   
    }  
    public void CheckBox(){
        string apexpagesgettingid= apexpages.currentpage().getparameters().get('id');
        webinarAttendee__c  web =[SELECT Id, Calendar_event__c FROM webinarAttendee__c WHERE Id =: apexpagesgettingid];
        web.Calendar_event__c = true;
        //this is my salesforce code;
        update web;
        
    }
    @future(callout = true)
    public static void updateEvent(String subject, String iId, String gId,string meeting,String LeadIn){
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
                // return null;
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
        
        String requestBody = '{"attendees":['+LeadIn+']}';
        
        System.debug('#### requestBody '+requestBody); 
        Http httpRq = new Http(); 
        HttpRequest httpRequest = new HttpRequest();
        HttpResponse HttpResponse = new HttpResponse();
        
        httpRequest.setEndpoint('https://www.googleapis.com/calendar/v3/calendars/info@mvclouds.com/events/'+ gId +'?sendNotifications=true&supportsAttachments=true&conferenceDataVersion=1');
        httpRequest.setMethod('PATCH');
        httpRequest.setBody(requestBody);
        httpRequest.setHeader('Content-Type', 'application/json'); 
        httpRequest.setHeader('Authorization','Bearer '+accessToken);
        
        try{
            HttpResponse = httpRq.send(httpRequest);
            if(HttpResponse.getStatusCode() == 200){       
                String strJSON = HttpResponse.getBody();
                System.debug(strJSON); 
                
            }else if(HttpResponse.getStatusCode() == 401){
                String errorMessage1 = 'Please refresh access token';
                
            }
            else{
                String errorMessage1 = 'Unexpected Error while communicating with Google Calendar API. '
                    +'Status '+HttpResponse.getStatus()+' and Status Code '+HttpResponse.getStatuscode();
                System.debug(HttpResponse.getBody());
            }
        }catch(System.Exception e){
            System.debug('#### Exception Executed : '+e.getMessage() + '  '+e.getStackTraceString() + ' '+e.getLineNumber());
            
        }
    }    
}