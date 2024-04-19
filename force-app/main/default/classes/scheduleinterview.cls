public without sharing class scheduleinterview {
    
    @AuraEnabled
    public static void submitrecord(string cs,string sas,string sda,string fs,string js,string gc,string dc,string prof,string result,string interid){
        Interview__c interview = new Interview__c ();
        interview.Id = interid;


        if(cs != null ) interview.Communication_Skills__c = cs;
        if(sas != null ) interview.Salesforce_Administrator_Skills__c = sas;
        if(sda != null ) interview.Salesforce_Development_Skills__c = sda;
        if(fs != null ) interview.Front_end_Skills__c = fs;        
        if(js != null ) interview.Java_Skills__c = js;
        if(gc != null ) interview.General_Comment__c = gc;
        if(dc != null ) interview.Development_Comment__c = dc;
        if(prof != null ) interview.Professionalisms__c = prof;
        if(result != null ) interview.Result__c = result;	
        update interview;
        Interview__c interviewDetails = [Select Id, Result__c, RecordType.Name, Job_Application__c, Job_Application__r.Contact__r.FirstName, Job_Application__r.Contact__r.LastName, Job_Application__r.Contact__r.Email from Interview__c Where Id =: interview.Id LIMIT 1];
        System.debug(interviewDetails);
        if(interviewDetails.Result__c == 'Passed' && interviewDetails.RecordType.Name == 'First Round'){
            String subjectGmail = 'Passed Interview';
            
            String bodyGmail = 'Hi Maitri,<br/>'+
                interviewDetails.Job_Application__r.Contact__r.FirstName+ ' ' + interviewDetails.Job_Application__r.Contact__r.LastName + ' have passed interview.<br/><br/>'+
                'Schedule Second Round:- <a href="https://dharmikmvclouds-developer-edition.ap4.force.com/demo?id='+interviewDetails.Job_Application__r.Id+'">Click here to schedule the interview Date & Time.</a>';
            
            String sendTo = 'MV Clouds<info@mvclouds.com>';
            System.debug(sendTo);
            GoogleGmailApi.sendGmail(subjectGmail,bodyGmail,sendTo);    
        }
        if(interviewDetails.Result__c == 'Passed' && interviewDetails.RecordType.Name == 'Second Round'){
            String subjectGmail = 'Passed Interview';
            
            String bodyGmail = 'Hi Dharmik,<br/>'+
                interviewDetails.Job_Application__r.Contact__r.FirstName+ ' ' + interviewDetails.Job_Application__r.Contact__r.LastName + ' have passed interview.<br/><br/>'+
                'Please do further process.';
            
            String sendTo = 'Dharmik Shah<dharmik@mvclouds.com>';
            System.debug(sendTo);
            GoogleGmailApi.sendGmail(subjectGmail,bodyGmail,sendTo);    
        }
    }       
    
    @AuraEnabled
    public static string test(string reid){
        Job_Application__c ja = [ SELECT Id, Status__c,Contact__r.Name,Job_Posting__r.Job_Name__c, Contact__r.Email, Contact__r.Experience__c, contact__r.Fresher_Experience__c, Contact__r.MobilePhone FROM Job_Application__c WHERE Id =: reid ];
        
        System.debug(ja);      
        if(ja.Status__c == 'New'){
            return 'new'+','+ja.Contact__r.Name +','+ ja.Job_Posting__r.Job_Name__c+','+ja.Contact__r.Email+','+ja.Contact__r.Experience__c+','+ja.Contact__r.Fresher_Experience__c+','+ja.Contact__r.MobilePhone;
        }
        if(ja.Status__c == 'First'){
            Interview__c inter = [SELECT Id, Interviewer__r.Name FROM Interview__c WHERE Job_Application__c =: reid LIMIT 1];
            return 'first'+','+ja.Contact__r.Name +','+ ja.Job_Posting__r.Job_Name__c+','+ja.Contact__r.Email+','+ja.Contact__r.Experience__c+','+ja.Contact__r.Fresher_Experience__c+','+ja.Contact__r.MobilePhone+','+inter.Interviewer__r.Name;
        }
        if(ja.Status__c == 'Second'){
            return 'second'+','+ja.Contact__r.Name +','+ ja.Job_Posting__r.Job_Name__c+','+ja.Contact__r.Email+','+ja.Contact__r.Experience__c+','+ja.Contact__r.Fresher_Experience__c+','+ja.Contact__r.MobilePhone;
        }
        
        
        return null;
    }    
    
    
    //TO check whether this is  is for reschedule or not
    @AuraEnabled 
    public static string resch(string reid){
        Job_Application__c ja = [ SELECT Id, Status__c, Contact__r.FirstName, Contact__r.Email FROM Job_Application__c WHERE Id =: reid ];
        Interview__c nter = [SELECT Id, Name, Time__c,Date__c, RecordTypeId FROM Interview__c WHERE Job_Application__r.Id =: reid ORDER BY CreatedDate DESC LIMIT 1];
        
        Interview__c nter1 = [SELECT Id,Communication_Skills__c, Salesforce_Administrator_Skills__c, Salesforce_Development_Skills__c, Front_end_Skills__c, Java_Skills__c, General_Comment__c, Development_Comment__c, Professionalisms__c, Result__c FROM Interview__c WHERE Job_Application__r.Id =: reid ORDER BY CreatedDate LIMIT 1];
        Interview__c nter2 = [SELECT Id,Communication_Skills__c, Salesforce_Administrator_Skills__c, Salesforce_Development_Skills__c, Front_end_Skills__c, Java_Skills__c, General_Comment__c, Development_Comment__c, Professionalisms__c, Result__c FROM Interview__c WHERE Job_Application__r.Id =: reid ORDER BY LastModifiedDate DESC LIMIT 1];
        DateTime interviewTime = DateTime.newInstance(nter.Date__c,nter.Time__c);
        DateTime currentTime = DateTime.Now();
        System.debug(interviewTime);
        System.debug(currentTime);
        System.debug(nter.Id);
        if(ja.Status__c == 'New'){
            return null;
        }else if(ja.Status__c == 'First'){
            if(currentTime <= interviewTime  ){
                return 're'+','+'First'+','+nter1.Communication_Skills__c+','+nter1.Salesforce_Administrator_Skills__c+','+nter1.Salesforce_Development_Skills__c+','+nter1.Front_end_Skills__c+','+nter1.Java_Skills__c+','+nter1.General_Comment__c+','+nter1.Development_Comment__c+','+nter1.Professionalisms__c+','+nter1.Result__c ;
            }else{
                return 'hey'+','+'hey'+','+nter1.Communication_Skills__c+','+nter1.Salesforce_Administrator_Skills__c+','+nter1.Salesforce_Development_Skills__c+','+nter1.Front_end_Skills__c+','+nter1.Java_Skills__c+','+nter1.General_Comment__c+','+nter1.Development_Comment__c+','+nter1.Professionalisms__c+','+nter1.Result__c ;
            }

        }else if(ja.Status__c == 'Second'){
            
            if(currentTime <= interviewTime  ){
                return 're'+','+'Second'+','+nter1.Communication_Skills__c+','+nter1.Salesforce_Administrator_Skills__c+','+nter1.Salesforce_Development_Skills__c+','+nter1.Front_end_Skills__c+','+nter1.Java_Skills__c+','+nter1.General_Comment__c+','+nter1.Development_Comment__c+','+nter1.Professionalisms__c+','+nter1.Result__c ;
            }else{
                return 'final'+','+'hey'+','+nter2.Communication_Skills__c+','+nter2.Salesforce_Administrator_Skills__c+','+nter2.Salesforce_Development_Skills__c+','+nter2.Front_end_Skills__c+','+nter2.Java_Skills__c+','+nter2.General_Comment__c+','+nter2.Development_Comment__c+','+nter2.Professionalisms__c+','+nter2.Result__c ;
            
            }

        }
        
        return null;
     
    }
    

    // Method For Interview Scheduling

    @AuraEnabled
    public static string scheduling(string reid,string inter,date dt,string tm,Boolean meetornot){
        System.debug('In method');
        String[] strTimeSplit = tm.split(':');
        Time timeChange = Time.newInstance( Integer.valueOf(strTimeSplit[0]),Integer.valueOf(strTimeSplit[1]),0,0);
        System.debug(timechange);
        Job_Application__c ja = [ SELECT Id, Status__c, Contact__r.FirstName, Contact__r.Email FROM Job_Application__c WHERE Id =: reid ];

        

        Interview__c interview = new Interview__c();  
              

        // Create Interview if none created
        
       if(ja.Status__c == 'New'){
            System.debug('Create new ');
            interview.Interviewer__c = inter;
            interview.Date__c = dt;
            interview.Time__c = timechange;
            interview.RecordTypeId = ja.Status__c == 'New' ? '0126F0000022cwXQAQ' :  '0126F0000022cwcQAA';
            interview.Job_Application__c = reid;
            insert interview; 
            
            String subject = 'First Round of Interview - '+ja.Contact__r.FirstName;
			
           if(meetornot){
            	createEvent(dt, timechange, subject ,inter, ja.Contact__r.Email,interview.Id+'');   
           }else{
            	createEvent_1(dt, timechange, subject ,inter, ja.Contact__r.Email,interview.Id+'');
           }
            
            
            return null;

            
        } else {

    
        Interview__c nter = [SELECT Id, Name, Time__c,Date__c,Google_Event_Id__c , RecordTypeId FROM Interview__c WHERE Job_Application__r.Id =: reid ORDER BY CreatedDate DESC LIMIT 1];
        DateTime interviewTime = DateTime.newInstance(nter.Date__c,nter.Time__c);
        DateTime currentTime = DateTime.Now();
        System.debug(interviewTime);
        System.debug(currentTime);
        if(ja.Status__c == 'First'){
            
            System.debug('in the method of first');
            
            if(currentTime <= interviewTime  ){
                
                System.debug('update first');
                // UPDATE THE FIRST INTERVIEW...
                interview.id = nter.id;
                interview.Interviewer__c = inter;
                interview.Date__c = dt;
                interview.Time__c = timechange;           
                interview.RecordTypeId = ja.Status__c == 'First' ? '0126F0000022cwXQAQ' : '';
                Update interview;
                
                
                String subject = 'Re Schedule First Round of Interview - '+ja.Contact__r.FirstName;
                updateEvent(dt, timechange, subject ,inter, ja.Contact__r.Email, interview.Id, nter.Google_Event_Id__c); 
                return null;

            }else{
                // Create Interview if Second created    
                // Create Second Interview here...
                System.debug('create second');
                interview.Interviewer__c = inter;
                interview.Date__c = dt;
                interview.Time__c = timechange;           
                interview.RecordTypeId = ja.Status__c == 'First' ? '0126F0000022cwcQAA' : '';
                interview.Job_Application__c = reid;
                insert interview;
                
                String subject = 'Second Round of Interview - '+ja.Contact__r.FirstName;
				
                if(meetornot){
                    createEvent(dt, timechange, subject ,inter, ja.Contact__r.Email,interview.Id+'');                    
                }else{
                    createEvent_1(dt, timechange, subject ,inter, ja.Contact__r.Email,interview.Id+'');
                }

                return null;
              
            }
        
        }else if(ja.Status__c == 'Second'){
            System.debug('in the method of second');
           
                 if( currentTime <= interviewTime ){
                //update second round 
                System.debug('update the second');
                interview.id = nter.id;
                interview.Interviewer__c = inter;
                interview.Date__c = dt;
                interview.Time__c = timechange;           
                interview.RecordTypeId = ja.Status__c == 'Second' ? '0126F0000022cwcQAA' : '';
                Update interview;
                
                String subject = 'Re Schedule Second Round of Interview - '+ja.Contact__r.FirstName;
                updateEvent(dt, timechange, subject ,inter, ja.Contact__r.Email, interview.Id, nter.Google_Event_Id__c); 
                return null;
            }else{
                return null;
            }
        }
        }

        return null;
    }
    
    @future(callout = true)
    public static void createEvent(Date selectDate, Time selectTime, String subject, String interviewer, String interviewee, String iId){
        
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
        
        Interviewer__c interviewTaker = [Select ID, Name, Email__c from Interviewer__c Where Id =: interviewer Limit 1];
        
        String DateForStart = selectDate.year()+'-'+selectDate.month()+'-'+selectDate.day() + 'T' + selectTime.hour() + ':' + selectTime.minute() + ':00' ;
        
        Time TimeEnd = selectTime;
            TimeEnd = selectTime.addMinutes(45);    
        
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
            '"description":"Your webcam should be on during the interview."}';
        
        System.debug('#### requestBody '+requestBody); 
        Http httpRq = new Http(); 
        HttpRequest httpRequest = new HttpRequest();
        HttpResponse HttpResponse = new HttpResponse();
        
        httpRequest.setEndpoint('https://www.googleapis.com/calendar/v3/calendars/info@mvclouds.com/events?sendNotifications=true&supportsAttachments=true&conferenceDataVersion=1&maxAttendees=5');
        httpRequest.setMethod('POST');
        httpRequest.setBody(requestBody);
        httpRequest.setHeader('Content-Type', 'application/json'); 
        httpRequest.setHeader('Authorization','Bearer '+accessToken);
        
        try{
            HttpResponse = httpRq.send(httpRequest);
            if(HttpResponse.getStatusCode() == 200){       
                String strJSON = HttpResponse.getBody();
                // System.debug(strJSON);
                List<Simple> s = (List<Simple>) JSON.deserialize('['+strJSON+']', List<simple>.class);
                Interview__c inter = new Interview__c();
                inter.Id = iId;
                inter.Google_Event_Id__c = s[0].Id;
                update inter;
            }else if(HttpResponse.getStatusCode() == 401){
                String errorMessage1 = 'Please refresh access token';
            }
            else{
                String errorMessage1 = 'Unexpected Error while communicating with Google Calendar API. '
                    +'Status '+HttpResponse.getStatus()+' and Status Code '+HttpResponse.getStatuscode();
            }
        }catch(System.Exception e){
            System.debug('#### Exception Executed : '+e.getMessage() + '  '+e.getStackTraceString() + ' '+e.getLineNumber());
            // return null;
        }
    }
    
    @future(callout = true)
    public static void createEvent_1(Date selectDate, Time selectTime, String subject, String interviewer, String interviewee, String iId){
        
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
        
        Interviewer__c interviewTaker = [Select ID, Name, Email__c from Interviewer__c Where Id =: interviewer Limit 1];
        
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
            '"description":"Please bring your laptop with you to the Interview."}';
        
        System.debug('#### requestBody '+requestBody); 
        Http httpRq = new Http(); 
        HttpRequest httpRequest = new HttpRequest();
        HttpResponse HttpResponse = new HttpResponse();
        
        httpRequest.setEndpoint('https://www.googleapis.com/calendar/v3/calendars/info@mvclouds.com/events?sendNotifications=true&supportsAttachments=true&maxAttendees=5');
        httpRequest.setMethod('POST');
        httpRequest.setBody(requestBody);
        httpRequest.setHeader('Content-Type', 'application/json'); 
        httpRequest.setHeader('Authorization','Bearer '+accessToken);
        
        try{
            HttpResponse = httpRq.send(httpRequest);
            if(HttpResponse.getStatusCode() == 200){       
                String strJSON = HttpResponse.getBody();
                List<Simple> s = (List<Simple>) JSON.deserialize('['+strJSON+']', List<simple>.class);
                Interview__c inter = new Interview__c();
                inter.Id = iId;
                inter.Google_Event_Id__c = s[0].Id;
                update inter;
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
    
    @future(callout = true)
    public static void updateEvent(Date selectDate, Time selectTime, String subject, String interviewer, String interviewee, String iId, String gId){
        
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
        
        Interviewer__c interviewTaker = [Select ID, Name, Email__c from Interviewer__c Where Id =: interviewer Limit 1];
        
        String DateForStart = selectDate.year()+'-'+selectDate.month()+'-'+selectDate.day() + 'T' + selectTime.hour() + ':' + selectTime.minute() + ':00' ;
        
        Time TimeEnd = selectTime;
            TimeEnd = selectTime.addMinutes(45);    
        
        
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
            '"description":"Please carry your laptop and resume with you for the interview."}';
        
        System.debug('#### requestBody '+requestBody); 
        Http httpRq = new Http(); 
        HttpRequest httpRequest = new HttpRequest();
        HttpResponse HttpResponse = new HttpResponse();
        
        httpRequest.setEndpoint('https://www.googleapis.com/calendar/v3/calendars/info@mvclouds.com/events/'+ gId +'?sendNotifications=true&supportsAttachments=true&maxAttendees=5');
        httpRequest.setMethod('PUT');
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
            
            }
        }catch(System.Exception e){
            System.debug('#### Exception Executed : '+e.getMessage() + '  '+e.getStackTraceString() + ' '+e.getLineNumber());
            
        }
    }

    @future(callout = true)
    public static void onlineEvent(Date selectDate, Time selectTime, String subject, String interviewer, String interviewee, String iId, String gId){
        
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
        
        Interviewer__c interviewTaker = [Select ID, Name, Email__c from Interviewer__c Where Id =: interviewer Limit 1];
        
        String DateForStart = selectDate.year()+'-'+selectDate.month()+'-'+selectDate.day() + 'T' + selectTime.hour() + ':' + selectTime.minute() + ':00' ;
        
        Time TimeEnd = selectTime;
            TimeEnd = selectTime.addMinutes(45);    
        
        
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
            '"description":"Your webcam should be on during the interview."}';
        
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
                
            }else if(HttpResponse.getStatusCode() == 401){
                String errorMessage1 = 'Please refresh access token';
                
            }
            else{
                String errorMessage1 = 'Unexpected Error while communicating with Google Calendar API. '
                    +'Status '+HttpResponse.getStatus()+' and Status Code '+HttpResponse.getStatuscode();
                
            }
        }catch(System.Exception e){
            System.debug('#### Exception Executed : '+e.getMessage() + '  '+e.getStackTraceString() + ' '+e.getLineNumber());
            // return null;
        }
    }
    
    
    public void scheduleInterview( String InterviewType ){
        /*Interview__c int = new Interview__c();

int.RecordTypeId = InterviewType == 'First Round' ? '0126F0000022cwXQAQ' : '0126F0000022cwcQAA';*/
    }
    
    
    @AuraEnabled
    public static List<String> getPickListValues(String ObjName,String FieldName){
        String[] values = new String[]{};
            String[] types = new String[]{ObjName};
                Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(FieldName).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {values.add(entry.getValue());}
            }
        }
        return values;  
    }
    
    @AuraEnabled
    public static List<Interviewer__c> getInterviewers(){
        List<Interviewer__c> Interviewers = [Select Id, Name, Email__c from Interviewer__c WHERE Active__c = true];
        return Interviewers;
    }
    
    
    public class simple {
        @AuraEnabled public String id;
    }
    
    @AuraEnabled
    public static string pdfview(string reid){
        Attachment attach = new Attachment();
        string pdfvalue;
        

        Job_Application__c job = new Job_Application__c();
        job =[SELECT Id,Contact__r.Id FROM Job_Application__c WHERE Id =: reid];
        String conid = job.Contact__r.Id;
        attach = [SELECT Id,Name,Body,ContentType FROM Attachment WHERE ParentId =: conid LIMIT 1];
        String contype = attach.ContentType;
        Blob attachbody = attach.Body;
        pdfvalue= '';
        pdfvalue= EncodingUtil.base64Encode(attachbody);

        return contype+','+pdfvalue;
        
    }  

    @future(callout = true)
    public static void cancelEvent(Date selectDate, Time selectTime, String subject, String interviewer, String interviewee, String iId, String gId){
        	
        System.debug('subject>>>>Can>>'+subject);
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
        Interviewer__c interviewTaker = [Select ID, Name, Email__c from Interviewer__c Where Id =: interviewer Limit 1];
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
            '"attendees": [{"email": "'+interviewTaker.Email__c+'"}],'+
            '"kind": "calendar#event",'+
            '"subject": "'+subject+'",'+
            '"conferenceData": {"createRequest": {"requestId": "aaa-bbbb-vv"}},'+
            '"description":""}';
        System.debug('#### requestBody '+requestBody);
        Http httpRq = new Http();
        HttpRequest httpRequest = new HttpRequest();
        HttpResponse HttpResponse = new HttpResponse();
        httpRequest.setEndpoint('https://www.googleapis.com/calendar/v3/calendars/info@mvclouds.com/events/'+ gId +'?sendNotifications=true&supportsAttachments=true&conferenceDataVersion=1&maxAttendees=5');
        httpRequest.setMethod('DELETE');
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
                
            }
        }catch(System.Exception e){
            System.debug('#### Exception Executed : '+e.getMessage() + '  '+e.getStackTraceString() + ' '+e.getLineNumber());
            // return null;
        }

        
    }

        @future(callout = true)
    public static void interviewerChange(Date selectDate, Time selectTime, String subject, String interviewer, String interviewee, String iId, String gId){
        
        
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
        
        Interviewer__c interviewTaker = [Select ID, Name, Email__c from Interviewer__c Where Id =: interviewer Limit 1];

        // Interview__c interviewww = [SELECT Id,Contact__c FROM Interview__c WHERE Contact__c =:interviewee LIMIT 1];
        
        String DateForStart = selectDate.year()+'-'+selectDate.month()+'-'+selectDate.day() + 'T' + selectTime.hour() + ':' + selectTime.minute() + ':00' ;
        
        Time TimeEnd = selectTime;
            TimeEnd = selectTime.addMinutes(45);            
        
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


    @future(callout = true)
    public static void createEventNotMeet(Date selectDate, Time selectTime, String subject, String interviewer, String interviewee, String iId){
        
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
        
        Interviewer__c interviewTaker = [Select ID, Name, Email__c from Interviewer__c Where Id =: interviewer Limit 1];
        
        String DateForStart = selectDate.year()+'-'+selectDate.month()+'-'+selectDate.day() + 'T' + selectTime.hour() + ':' + selectTime.minute() + ':00' ;
        
        Time TimeEnd = selectTime;
        if(subject.contains('First') || subject.contains('1')){
            TimeEnd = selectTime.addMinutes(60);    
        }else if(subject.contains('Second') || subject.contains('2')){
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
            '"description":" Please carry your laptop and resume with you for the interview."}';
        
        System.debug('#### requestBody '+requestBody); 
        Http httpRq = new Http(); 
        HttpRequest httpRequest = new HttpRequest();
        HttpResponse HttpResponse = new HttpResponse();
        
        httpRequest.setEndpoint('https://www.googleapis.com/calendar/v3/calendars/info@mvclouds.com/events?sendNotifications=true&supportsAttachments=true&maxAttendees=5');
        httpRequest.setMethod('POST');
        httpRequest.setBody(requestBody);
        httpRequest.setHeader('Content-Type', 'application/json'); 
        httpRequest.setHeader('Authorization','Bearer '+accessToken);
        
        try{
            HttpResponse = httpRq.send(httpRequest);
            if(HttpResponse.getStatusCode() == 200){       
                String strJSON = HttpResponse.getBody();
                // System.debug(strJSON);
                List<Simple> s = (List<Simple>) JSON.deserialize('['+strJSON+']', List<simple>.class);
                Interview__c inter = new Interview__c();
                inter.Id = iId;
                inter.Google_Event_Id__c = s[0].Id;
                update inter;
            }else if(HttpResponse.getStatusCode() == 401){
                String errorMessage1 = 'Please refresh access token';
                
            }
            else{
                String errorMessage1 = 'Unexpected Error while communicating with Google Calendar API. '
                    +'Status '+HttpResponse.getStatus()+' and Status Code '+HttpResponse.getStatuscode();
                
            }
        }catch(System.Exception e){
            System.debug('#### Exception Executed : '+e.getMessage() + '  '+e.getStackTraceString() + ' '+e.getLineNumber());
            // return null;
        }
    }
}