public class CalendarEvent {
  
    public  void createEvent(Date selectDate, Time selectTime, String subject, String LeadIn, String interviewee, String iId){
        // String consumerKey='15485663049-lvl2vl416emj8ovasiuqdgjv8de4u86r.apps.googleusercontent.com';
        // String clientSecret='25G2q99Y9DiTC81wx14WBQRI';
        
        // Info
        String consumerKey='129447479512-ph7gb5m0gouhmt85hgd4fj11523kvs6e.apps.googleusercontent.com';
        String clientSecret='lOx7jzEUdlfUXAqwvfDeOdwc'; 
        
        String googleoAuthUrl='https://accounts.google.com/o/oauth2/auth?'; 
        String redirect_uri = 'https://naveen143-dev-ed.my.salesforce.com/apex/GoogleCalenderoAuth';
        String calendar_Scope = 'https://www.googleapis.com/auth/calendar'; 
        
        /* String googleoAuthUrl='https://accounts.google.com/o/oauth2/auth?'; 
String redirect_uri = 'https://dharmikmv-dev-ed--c.ap4.visual.force.com/apex/GoogleCalenderoAuth';
String calendar_Scope = 'https://www.googleapis.com/auth/calendar'; */
        
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
            // return null;
        }
        
        //Lead LeadEmail = [Select ID, Name, Email from Lead Where Email =: LeadIn Limit 1];
        
        String DateForStart = selectDate.year()+'-'+selectDate.month()+'-'+selectDate.day() + 'T' + selectTime.hour() + ':' + selectTime.minute() + ':00' ;
        
        Time TimeEnd = selectTime;
        if(subject.contains('First')){
            TimeEnd = selectTime.addMinutes(30);    
        }else if(subject.contains('Second')){
            TimeEnd = selectTime.addMinutes(45);    
        }
        
        
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
            '"attendees": [{"email": "'+LeadIn+'"}],'+
            '"kind": "calendar#event",'+
            '"summary": "'+subject+'",'+
            '"conferenceData": {"createRequest": {"requestId": "aaa-bbbb-vv"}},'+
            '"description":""}';
        
        System.debug('#### requestBody '+requestBody); 
        Http httpRq = new Http(); 
        HttpRequest httpRequest = new HttpRequest();
        HttpResponse HttpResponse = new HttpResponse();
        httpRequest.setEndpoint('https://www.googleapis.com/calendar/v3/calendars/naveen.k@mvclouds.com/events?sendNotifications=true&supportsAttachments=true&conferenceDataVersion=1&maxAttendees=5');
        httpRequest.setMethod('POST');
        httpRequest.setBody(requestBody);
        httpRequest.setHeader('Content-Type', 'application/json'); 
        httpRequest.setHeader('Authorization','Bearer '+accessToken);
        
        try{
            HttpResponse = httpRq.send(httpRequest);
            if(HttpResponse.getStatusCode() == 200){       
                String strJSON = HttpResponse.getBody();
                // System.debug(strJSON);
                /*  List<Simple> s = (List<Simple>) JSON.deserialize('['+strJSON+']', List<simple>.class);
Interview__c inter = new Interview__c();
inter.Id = iId;
inter.Google_Event_Id__c = s[0].Id;
update inter; */
            }else if(HttpResponse.getStatusCode() == 401){
                String errorMessage1 = 'Please refresh access token';
                // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errorMessage1));
                // return null;
            }
            else{
                String errorMessage1 = 'Unexpected Error while communicating with Google Calendar API. '
                    +'Status '+HttpResponse.getStatus()+' and Status Code '+HttpResponse.getStatuscode();
                // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errorMessage1));
                // return null;
            }
        }catch(System.Exception e){
            System.debug('#### Exception Executed : '+e.getMessage() + '  '+e.getStackTraceString() + ' '+e.getLineNumber());
            // return null;
        }
    }
    
    /*  @future(callout = true)
public static void updateEvent(Date selectDate, Time selectTime, String subject, String interviewer, String interviewee, String iId, String gId){
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
// return null;
}

//   Interviewer__c interviewTaker = [Select ID, Name, Email__c from Interviewer__c Where Id =: interviewer Limit 1];

String DateForStart = selectDate.year()+'-'+selectDate.month()+'-'+selectDate.day() + 'T' + selectTime.hour() + ':' + selectTime.minute() + ':00' ;

Time TimeEnd = selectTime;
if(subject.contains('First')){
TimeEnd = selectTime.addMinutes(30);    
}else if(subject.contains('Second')){
TimeEnd = selectTime.addMinutes(45);    
}


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
'"attendees": [{"email": "'+interviewTaker.Email__c+'"},{"email": "'+interviewee+'"}],'+
'"kind": "calendar#event",'+
'"summary": "'+subject+'",'+
'"conferenceData": {"createRequest": {"requestId": "aaa-bbbb-vv"}},'+
'"description":""}';

System.debug('#### requestBody '+requestBody); 
Http httpRq = new Http(); 
HttpRequest httpRequest = new HttpRequest();
HttpResponse HttpResponse = new HttpResponse();

httpRequest.setEndpoint('https://www.googleapis.com/calendar/v3/calendars/info@mvclouds.com/events/'+ gId +'?sendNotifications=true&supportsAttachments=true&conferenceDataVersion=1&maxAttendees=5');
httpRequest.setMethod('PUT');
httpRequest.setBody(requestBody);
httpRequest.setHeader('Content-Type', 'application/json'); 
httpRequest.setHeader('Authorization','Bearer '+accessToken);

try{
HttpResponse = httpRq.send(httpRequest);
if(HttpResponse.getStatusCode() == 200){       
String strJSON = HttpResponse.getBody();
System.debug(strJSON); 
// List<Simple> s = (List<Simple>) JSON.deserialize('['+strJSON+']', List<simple>.class);
// Interview__c inter = new Interview__c(); 
// inter.Id = iId;
// inter.Google_Event_Id__c = s[0].Id; 
// update inter;
}else if(HttpResponse.getStatusCode() == 401){
String errorMessage1 = 'Please refresh access token';
// ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errorMessage1));
// return null;
}
else{
String errorMessage1 = 'Unexpected Error while communicating with Google Calendar API. '
+'Status '+HttpResponse.getStatus()+' and Status Code '+HttpResponse.getStatuscode();
// ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errorMessage1));
// return null;
}
}catch(System.Exception e){
System.debug('#### Exception Executed : '+e.getMessage() + '  '+e.getStackTraceString() + ' '+e.getLineNumber());
// return null;
}
}  */
    
    
    // public void scheduleInterview( String InterviewType ){
    /*Interview__c int = new Interview__c();

int.RecordTypeId = InterviewType == 'First Round' ? '0126F0000022cwXQAQ' : '0126F0000022cwcQAA';*/
}