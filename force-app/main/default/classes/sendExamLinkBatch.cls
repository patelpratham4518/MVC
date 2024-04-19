public class sendExamLinkBatch implements Database.Batchable<Contact>, Database.AllowsCallouts, Database.Stateful{ 

    private String collegeName;

    public sendExamLinkBatch(String accId) {
        System.debug('accId ==> '+accId);
        List<Account> college = [SELECT Id, Name FROM Account WHERE Id =: accId LIMIT 1];
        if (college.size() > 0) {
            collegeName = college[0].Name;
        }
        System.debug('collegeName ==> '+collegeName);
    }

    public List<Contact> start(Database.BatchableContext info){ 
        System.debug('sendExamLinkBatch Start');
        List<Contact> studentList = new List<Contact>();
        studentList = [SELECT Id, FirstName, LastName, Email, Enrollment_No__c FROM Contact WHERE College_Name__c =: collegeName AND Id = '0036F00004BgKYlQAN'];
        System.debug('Student List Size => '+studentList.size());
        return studentList; 
    }

    public void execute(Database.BatchableContext info, List<Contact> contactList){
        System.debug('sendExamLinkBatch Execute');
        for(Contact con : contactList){ 
            System.debug('con ==> '+con);
            sendGmail(con);
            // sendReminderGmail(con);
        } 
    }

    public void finish(Database.BatchableContext info){     
        System.debug('sendExamLinkBatch Finish');
    }

    public static void sendGmail(Contact con){

        String subjectGmail = 'MV Clouds - Unique Link to start your test';
        String bodyGmail = 'Dear ' + con.FirstName;
        bodyGmail += ',<br/><br/>Please find below the link for ' + con.Enrollment_No__c + ' to start your online test.<br/><br/>';
        bodyGmail += '<a href="https://dharmikmv-dev-ed.my.salesforce-sites.com/questions?conId='+con.Id+'">https://dharmikmv-dev-ed.my.salesforce-sites.com/questions?conId='+con.Id+'</a><br/><br/>';
        bodyGmail += 'Please note that this link is unique to you and you are not able to shared with anyone else.<br/>';
        bodyGmail += 'Please make sure you give necessary permissions<br/><br/>';
        bodyGmail += '<b>Instructions for the test:</b>';
        bodyGmail += '<ol style="margin: 0; padding-inline-start: 20px;"><li>Every candidate has a unique link to take the test. You cannot use someone else\'s link to begin the test.</li>';
        bodyGmail += '<li>Please give the camera and screen recording permission to start the test.</li>';
        bodyGmail += '<li>Candidates will have to give permission to share the entire screen.</li>';
        bodyGmail += '<li>The test has two parts- Aptitude test and a practical test on programming two languages of your choice.</li>';
        bodyGmail += '<li>For the technical test, please save the answers before proceeding to the next one.</li>';
        bodyGmail += '<li>You will have one hour in total to submit both the aptitude and practical test. The entire test will be auto-submitted after an hour of beginning the test.</li>';
        bodyGmail += '<li>If any candidate will be caught cheating during the test, they will be disqualified.</li>';
        bodyGmail += '<li>Timer will start when you click on Start Test.</li>';
        bodyGmail += '<li>Once you submit the test, you will not be able to go back to the test.</li></ol><br/><br/>';
        
        bodyGmail += 'Regards and Best of Luck,<br/>MV Clouds Team';
        String sendTo = con.Email;
		
		String errorMessage ='';
                
        string before = 'From: MV Clouds <info@mvclouds.com>\n'+
                        'To: '+sendTo+'\n'+
                        'Subject: '+subjectGmail+'\n' +
                        'Content-Type: text/html \n\n'+bodyGmail;
                        
        System.debug(before);            	
        Blob beforeblob = Blob.valueOf(before);
        string paramvalue = EncodingUtil.base64Encode(beforeblob);
        paramvalue = paramvalue.replace('+', '-');
        paramvalue = paramvalue.replace('/', '_');
        System.debug(paramvalue);

        Http httpMail = new Http();
        HttpRequest httpReqMail = new HttpRequest();
        HttpResponse httpResMail = new HttpResponse();
        httpReqMail.setEndpoint('callout:Gmail/gmail/v1/users/me/messages/send');
        httpReqMail.setMethod('POST');
        httpReqMail.setHeader('Content-Type', 'application/json');
        httpReqMail.setHeader('Content-Length', '-1');
        String refreshToknBody = '{"userId":"me","raw":"'+paramvalue+'"}';
        system.debug(refreshToknBody);
        httpReqMail.setBody(refreshToknBody);
    
        try{
            httpResMail = httpMail.send(httpReqMail); 
            if(httpResMail.getStatusCode() == 200){
                System.debug(httpResMail.getBody()); 
            }else{
                String errorMessageMail = 'Unexpected Error while communicating with Google Calendar API. '
                    +'Status '+httpResMail.getBody()+' and Status Code '+httpResMail.getStatuscode();
                System.debug('Error ' + errorMessageMail);
                System.debug(httpResMail);
            }
        }catch(System.Exception e){
            
            System.debug('#### Exception Executed '+e.getStackTraceString() + ' '+e.getMessage());
        } 
    }

    public static void sendReminderGmail(Contact con){

        String subjectGmail = 'MV Clouds - Exam Details';
        String bodyGmail = 'Hello ' + con.FirstName;
        bodyGmail += ',<br/><br/>Greetings from MV Clouds!<br/><br/>';
        bodyGmail += 'This email is to update you for the upcoming online test scheduled for November 7, 2023.<br/><br/>';
        bodyGmail += 'Here are the details for the test:<br/>';
        bodyGmail += '<b>Date:</b> November 7, 2023<br/>';
        bodyGmail += '<b>Time:</b> Can be taken anytime between 2:00 pm to 4:00 pm<br/>';
        bodyGmail += '<b>Duration:</b> 1 hour<br/><br/>';
        bodyGmail += 'Please ensure that you are ready to take and submit the test within the specified time frame.<br/>';
        bodyGmail += 'The test link will be provided to you an hour before the scheduled time. The link will activate at 2:00 pm only.<br/><br/>';
        bodyGmail += 'We wish you the best of luck on the upcoming test!<br/><br/>';
        bodyGmail += 'Regards,<br/>MV Clouds Team.';
        String sendTo = con.Email;
		
		String errorMessage ='';
                
        string before = 'From: MV Clouds <info@mvclouds.com>\n'+
                        'To: '+sendTo+'\n'+
                        'Subject: '+subjectGmail+'\n' +
                        'Content-Type: text/html \n\n'+bodyGmail;
                        
        System.debug(before);            	
        Blob beforeblob = Blob.valueOf(before);
        string paramvalue = EncodingUtil.base64Encode(beforeblob);
        paramvalue = paramvalue.replace('+', '-');
        paramvalue = paramvalue.replace('/', '_');
        System.debug(paramvalue);

        Http httpMail = new Http();
        HttpRequest httpReqMail = new HttpRequest();
        HttpResponse httpResMail = new HttpResponse();
        httpReqMail.setEndpoint('callout:Gmail/gmail/v1/users/me/messages/send');
        httpReqMail.setMethod('POST');
        httpReqMail.setHeader('Content-Type', 'application/json');
        httpReqMail.setHeader('Content-Length', '-1');
        String refreshToknBody = '{"userId":"me","raw":"'+paramvalue+'"}';
        system.debug(refreshToknBody);
        httpReqMail.setBody(refreshToknBody);
    
        try{
            httpResMail = httpMail.send(httpReqMail); 
            if(httpResMail.getStatusCode() == 200){
                System.debug(httpResMail.getBody()); 
            }else{
                String errorMessageMail = 'Unexpected Error while communicating with Google Calendar API. '
                    +'Status '+httpResMail.getBody()+' and Status Code '+httpResMail.getStatuscode();
                System.debug('Error ' + errorMessageMail);
                System.debug(httpResMail);
            }
        }catch(System.Exception e){
            
            System.debug('#### Exception Executed '+e.getStackTraceString() + ' '+e.getMessage());
        } 
    }
 }