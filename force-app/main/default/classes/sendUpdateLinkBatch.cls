public class sendUpdateLinkBatch implements Database.Batchable<Contact>, Database.AllowsCallouts, Database.Stateful{ 

    private String collegeId;
    private List<String>  contactIds;

    public sendUpdateLinkBatch(String collegeIdStr, List<String> contactIdList) {
        System.debug('sendUpdateLinkBatch');
        collegeId = collegeIdStr;
        contactIds = contactIdList;
        System.debug('collegeId ==> '+collegeId);
        System.debug('contactIds ==> '+contactIds);
    }

    public List<Contact> start(Database.BatchableContext info){ 
        System.debug('sendUpdateLinkBatch Start');
        List<Contact> studentList = new List<Contact>();
        studentList = [SELECT Id, FirstName, LastName, Email, Enrollment_No__c FROM Contact WHERE Id IN: contactIds];
        return studentList; 
    }

    public void execute(Database.BatchableContext info, List<Contact> contactList){
        System.debug('sendUpdateLinkBatch Execute');
        for(Contact con : contactList){ 
            System.debug('con ==> '+con);
            sendGmail(con, collegeId);
        } 
    }

    public void finish(Database.BatchableContext info){     
        System.debug('sendUpdateLinkBatch Finish');
    }

    public static void sendGmail(Contact con, String collegeId){

        String subjectGmail = 'MV Clouds - Register For Placement Drive';
        String bodyGmail = 'Hello ' + con.FirstName;
        bodyGmail += ',<br/><br/>Greetings for the day!';
        bodyGmail += '<br/><br/>Please find below the registration link for the placement drive.';
        bodyGmail += '<br/><a href="https://dharmikmv-dev-ed.my.salesforce-sites.com/advanceStudentRegistrationPage?College_Id='+collegeId+'&Id='+con.Id+'"> Register Link </a><br/><br/>';
        bodyGmail += 'Interested candidates will be required to register through the above link before 10:00 a.m. on September 26, 2023. Only those candidates who have registered through the link will be able to participate in the campus drive.<br/><br/>';
        bodyGmail += 'The first round of the online test will taken on September 27, 2023 from 11:00 a.m. and you will be able to take the examination only till 1:00 p.m. There will be a separate examination link sent before the test.<br/><br/>';
        bodyGmail += '<b>Note: </b>This campus drive is only for the position of a Salesforce Developer Intern.<br/><br/>';
        bodyGmail += 'If you have any questions or concerns, feel free to contact us.<br/><br/>'; 
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
            // httpResMail = httpMail.send(httpReqMail); 
            // if(httpResMail.getStatusCode() == 200){
            //     System.debug(httpResMail.getBody()); 
            // }else{
            //     String errorMessageMail = 'Unexpected Error while communicating with Google Calendar API. '
            //         +'Status '+httpResMail.getBody()+' and Status Code '+httpResMail.getStatuscode();
            //     System.debug('Error ' + errorMessageMail);
            //     System.debug(httpResMail);
            // }
        }catch(System.Exception e){
            
            System.debug('#### Exception Executed '+e.getStackTraceString() + ' '+e.getMessage());
        } 
    }
 }