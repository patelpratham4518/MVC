public class LeaveController {

    @AuraEnabled
    public static String createleave(Date Startdate, Date Enddate, String Daytype, String Mentor, String Reason){

        try{

            User usr = [SELECT Id, ContactId, Contact.Name FROM User WHERE Id =: UserInfo.getUserId()];

            Leave__c l = new Leave__c();
            l.Start_Date__c = Startdate;
            l.End_Date__c = Enddate;
            l.Mentor__c = Mentor;
            l.Day__c = Daytype;
            l.Reason__c = Reason;
            l.Contact_Trainee__c = usr.ContactId;
            l.Status__c = 'Pending for Approval';
            insert l;

            String sd = String.valueOf(l.Start_Date__c).removeEnd('00:00:00');
            String ed = String.valueOf(l.End_Date__c).removeEnd('00:00:00');

            String bodygmail = 'Hi '+Mentor+', <br/> <br/>';
            // bodygmail += 'Ravi is Taking Leave on <b>' +Startdate+ '</b> to the <b>' +Enddate+ '</b>. ';
            bodygmail += +usr.Contact.Name+ ' is Taking Leave on <b>' +sd+ '</b> to the <b>' +ed+ '</b>. ';
            bodygmail += 'So Please approve Leave of ' +usr.Contact.Name;
            bodygmail += '. Here is the Reason of their Leave. <br/><br/> <b>'+Reason +'</b>';
            bodygmail += '<br/> <br/> <a href=\"https://mvclouds5-dev-ed.my.salesforce.com/'+l.Id+'" target="_blank"> Click here </a> is for approve or reject leave.';
            bodygmail += '<br/> <br/> Thanks,';
            bodygmail += '<br/>Mv Team';
            
            String mentoremail = '';
            if(Mentor == 'Devansh'){
                mentoremail = 'devansh.s@mvclouds.com';
            }else if(Mentor == 'Ravi'){
                System.debug('Ravi');
                mentoremail = 'ravi.m@mvclouds.com';
            }else if(Mentor == 'Ritu'){
                mentoremail = 'ritu.p@mvclouds.com';
            }else if(Mentor == 'Karan'){
                mentoremail = 'karan.p@mvclouds.com';
            }else if(Mentor == 'Prakash'){
                mentoremail = 'prakash.m@mvclouds.com';
            }else if(Mentor == 'Nishit'){
                mentoremail = 'nishit.s@mvclouds.com';
            }else if(Mentor == 'Yash'){
                mentoremail = 'yash.p@mvclouds.com';
            }

            mentoremail += ', hr@mvclouds.com, dharmik@mvclouds.com';

            sendGmail('Approval for Leave', bodygmail, mentoremail);

            return 'Success';
        } catch(Exception e){
            System.debug('E->');
            return 'Error';
        }

        
    }

    @future (callout=true) 
    public static void sendGmail(String subjectMail,String bodyGmail,String sendTo){ 
        String errorMessage =''; 
        string before = 'From: avc <abc@abc.com>\n'+ 
        'To: '+sendTo+'\n'+ 
        'Subject: '+subjectMail+'\n' + 
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
                String errorMessageMail = 'Unexpected Error while communicating with Google Calendar API. ' +'Status '+httpResMail.getBody()+' and Status Code '+httpResMail.getStatuscode(); 
                System.debug('Error ' + errorMessageMail); 
                System.debug(httpResMail); 
            } 
        }catch(System.Exception e){ 
            System.debug('#### Exception Executed '+e.getStackTraceString() + ' '+e.getMessage()); 
        } 
    }

    @AuraEnabled
    public static List<Leave__c> pendingLeavesList(){
        try {
            List<Leave__c> pendingLeaves = new List<Leave__c>();
            String pendStatus = 'Pending for Approval';
            User usr = [SELECT Id, ContactId, Contact.Name FROM User WHERE Id =: UserInfo.getUserId()];
            // pendingLeaves = [SELECT Id, Name, Start_Date__c, End_Date__c, Day__c, Reason__c, Contact_Trainee__c, Mentor__c, Status__c FROM Leave__c WHERE Contact_Trainee__c =: USR.ContactId];
            pendingLeaves = [SELECT Id, Name, Start_Date__c, End_Date__c, Day__c, Reason__c, Contact_Trainee__c, Mentor__c, Status__c FROM Leave__c WHERE Status__c = 'Pending for Approval' AND Contact_Trainee__c = :usr.ContactId];
            System.debug('pendingLeaves ==>' + pendingLeaves);
            return pendingLeaves;
        } catch (Exception e) {
            System.debug('#### Exception Called ==> '+e.getStackTraceString() + ' || '+e.getMessage()); 
            return null;
        }
    }

    @AuraEnabled
    public static List<Leave__c> allLeavesList(){
        try {
            List<Leave__c> allLeaves = new List<Leave__c>();
            User usr = [SELECT Id, ContactId, Contact.Name FROM User WHERE Id =: UserInfo.getUserId()];
            allLeaves = [SELECT Id, Name, Start_Date__c, End_Date__c, Day__c, Reason__c, Contact_Trainee__c, Mentor__c, Status__c FROM Leave__c WHERE Contact_Trainee__c =: USR.ContactId];
            // allLeaves = [SELECT Id, Name, Start_Date__c, End_Date__c, Day__c, Reason__c, Contact_Trainee__c, Mentor__c, Status__c FROM Leave__c WHERE Status__c = 'Pending Approved' AND Contact_Trainee__c = :usr.ContactId];
            System.debug('allLeaves ==>' + allLeaves);
            return allLeaves;
        } catch (Exception e) {
            System.debug('#### Exception Called ==> '+e.getStackTraceString() + ' || '+e.getMessage()); 
            return null;
        }
    }

}