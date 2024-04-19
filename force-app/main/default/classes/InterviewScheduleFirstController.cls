public class InterviewScheduleFirstController {
    // private Interview__c interview;
    // // public Interview__c inte{get;set;}
    public Contact cont{get;set;}
    public String currentRecordCandidateId {get;set;} 
    public Date selectDate{get;set;}
    public Time selectTime{get;set;}
    public string selectedUser{get; set;}
    public String showStatus{get;set;}
    public String accessToken;
    
    // Your CLient ID Here
    public Final static String consumerKey='15485663049-lvl2vl416emj8ovasiuqdgjv8de4u86r.apps.googleusercontent.com';
    //public Final static String consumerKey='324608710349-5uolg7kglp6cs9l902mt3h44hbhnckre.apps.googleusercontent.com';//Info
    // Your Client Secret Here
    public Final static String clientSecret='25G2q99Y9DiTC81wx14WBQRI'; 
    //public Final static String clientSecret='k-YojFTMGpFtyDSH7JpxKIvO' //Info
    
    
    public static String googleoAuthUrl='https://accounts.google.com/o/oauth2/auth?'; 
    // Your redirect URI here that you entered while creating the App in Google API console
    public static String redirect_uri = 'https://dharmikmv-dev-ed--c.ap4.visual.force.com/apex/GoogleCalenderoAuth';     
    
    public static String calendar_Scope = 'https://www.googleapis.com/auth/calendar'; 
    
    
    public InterviewScheduleFirstController() {
        currentRecordCandidateId  = ApexPages.CurrentPage().getparameters().get('Id');
        
        //list<Candidate__c> currentRecordContactId = [SELECT Contact__c FROM Candidate__c WHERE Id =: currentRecordCandidateId LIMIT 1 ];
        
        List<Job_Application__c> currentRecordContactId = [SELECT Contact__c FROM Job_Application__c WHERE Id =: currentRecordCandidateId LIMIT 1 ]; 
        
        cont = [SELECT Id, Name, Email, MobilePhone, MailingStreet, Type_of_Degree__c,Gender__c, College_Name__c, Branch__c, CGPA_or_Percentage__c, Year_Of_Passing__c, Total_Experience__c, Status__c 
                FROM Contact 
                WHERE Id =: currentRecordContactId[0].Contact__c ];
    }
    
    
    public PageReference submit(){
        
        String errorMessage ='';
            
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
                return null;
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
            return null;
        }
        
        
        User usrInterviewer = [select Id, Email from User Where Id =: selectedUser LIMIT 1];        
        
        
        system.debug('time'+selectTime);
        String DateForStart = selectDate.year()+'-'+selectDate.month()+'-'+selectDate.day() + 'T' + selectTime.hour() + ':' + selectTime.minute() + ':00' ;
        
        Time TimeEnd = selectTime;
        TimeEnd = selectTime.addMinutes(30);
        
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
            '"attendees": [{"email": "'+ usrInterviewer.Email +'"},{"email": "'+ cont.Email +'"},{"email": "kushalbagadia.kpb@gmail.com"}],'+
            '"kind": "calendar#event",'+
            '"summary": "Schedule Interview",'+
            '"conferenceData": {"createRequest": {"requestId": "aaa-bbbb-vv"}},'+
            '"description":"<h3>Click Here.(Only for Interviewer)</h3>https://dharmikmvclouds-developer-edition.ap4.force.com/InterviewRecordLogin?Id='+ currentRecordCandidateId +'"}';
        
        System.debug('#### requestBody '+requestBody); 
        Http httpRq = new Http(); 
        HttpRequest httpRequest = new HttpRequest();
        HttpResponse HttpResponse = new HttpResponse();
        
        httpRequest.setEndpoint('https://www.googleapis.com/calendar/v3/calendars/kushal.b@mvclouds.com/events?sendNotifications=true&supportsAttachments=true&conferenceDataVersion=1&maxAttendees=5');
        httpRequest.setMethod('POST');
        httpRequest.setBody(requestBody);
        httpRequest.setHeader('Content-Type', 'application/json');
        httpRequest.setHeader('Authorization','Bearer '+accessToken);
        
        try{
            HttpResponse = httpRq.send(httpRequest);
            if(HttpResponse.getStatusCode() == 200){       
                System.debug('Calendar Created Successfully '+HttpResponse.getBody());
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Event Created Successfully '));
            }else if(HttpResponse.getStatusCode() == 401){
                String errorMessage1 = 'Please refresh access token';
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errorMessage1));
                return null;
            }
            else{
                String errorMessage1 = 'Unexpected Error while communicating with Google Calendar API. '
                        +'Status '+HttpResponse.getStatus()+' and Status Code '+HttpResponse.getStatuscode();
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errorMessage1));
                return null;
            }
        }catch(System.Exception e){
            System.debug('#### Exception Executed : '+e.getMessage() + '  '+e.getStackTraceString() + ' '+e.getLineNumber());
            return null;
        }
        
        
        /*Interview__c interview = new Interview__c();
        interview.Interviewer__c = selectedUser;
        interview.InterviewDate__c = selectDate;
        interview.StartTime__c = selectTime;
        interview.Candidate__c = currentRecordCandidateId;
        
        insert interview;*/
        
        return null;
    }
    
    public List<SelectOption> getUser() {
        List<SelectOption> UserOptions = new List<SelectOption>();
        UserOptions.add( new SelectOption('','--Select--'));
        for(User uc : [SELECT Id, Name FROM User ]){
            UserOptions.add(new SelectOption(uc.id, uc.Name));  
        }
        return UserOptions;
    }
}