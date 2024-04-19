public with sharing class LeaveDashboardClass {
    public ApexPages.StandardSetController controller {set;get;}

    @AuraEnabled
    public static string getUserType(string userid){
        System.debug('userid>>>'+userid);
        id getContactId = [select id, contactId from User where id = : userid].contactId;
        System.debug('getContactId>>>'+getContactId);
        String userType = [SELECT Id, Name,ContactType__c FROM Contact WHERE Id =: getContactId].ContactType__c;
        System.debug(userType);
        return userType;    
    }
    
    @AuraEnabled(cacheable=true)
        public static List<Leave__c> leaveData() {
        system.debug('testing');
        List<Leave__c> leaves = [SELECT Id, Name, Contact_Trainee__r.Name, Reason__c, Leave_Type__c, Status__c, Day__c, Mentor__c FROM Leave__c];
        System.debug('Leave Log--->>>'+leaves);
        return leaves;
    }

    // public LeaveDashboardClass (){
    //     System.debug('=======');
    //     List<Leave__c> leaves = [SELECT Id, Name, Contact_Trainee__r.Name,Reason__c, Leave_Type__c, Status__c, Day__c  FROM Leave__c];
    //     controller=new Apexpages.StandardSetController(leaves);
    //     controller.setPageSize(5);
    // }
    @AuraEnabled
    public static void updateSatus(String recId, String status){
        System.debug('leaveRec' +recId);
        Leave__c leaveRec=[select Id,Status__c from Leave__c where Id=:recId];
        leaveRec.Status__c= status;
        update leaveRec;

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

    // Used In LeaveTrigger Trigger
    public static string ApproveMail(List<Leave__c> SendMailDetail){
        try{
            system.debug('Trainee Email'+SendMailDetail);
    
            for(Leave__c MailDetail : SendMailDetail){
                System.debug('MailDetail.Contact_Trainee__c-->'+ MailDetail.Contact_Trainee__c);

                Contact leaveContact = [SELECT Id, Name, Email, MobilePhone, Slack_Id__c FROM Contact WHERE Id =: MailDetail.Contact_Trainee__c];

                String ConEmail = leaveContact.Email;                    
                System.debug('ConEmail-->'+ConEmail);
                String MobileNO = leaveContact.MobilePhone;
                String ConNm = leaveContact.Name;
                String slackIdofApplyer = leaveContact.Slack_Id__c;
                String Mdate = String.valueOf(MailDetail.Start_Date__c).removeEnd('00:00:00');
                String Mdate1 = String.valueOf(MailDetail.End_Date__c).removeEnd('00:00:00');
                if(MailDetail.Status__c == 'Approved'){
                    System.debug('---Approve--');
                    String bodygmail = 'Hi '+ConNm+', <br/> <br/>';
                    bodygmail += ' I hope you are doing well! <br /><br />';
                    bodygmail += 'I have received your request for leave from <b>'+ Mdate + '</b> to <b>' + Mdate1 + ' </b>This notification serves as confirmation that your request for leave has been <b>Approved</b>. <br /><br />';
                    bodygmail += 'Have a great day ahead! <br /><br />';
                    bodygmail += 'Thanks and regards,<br /><br />';
                    bodygmail += 'MV Team';
                    system.debug('Trainee Email id : ' + ConEmail);
                    sendGmail('Leave Status', bodygmail, ConEmail);

                    String UserName = ConNm;
                    String WhatsappMsg = '';
                    WhatsappMsg += 'Hi ' + UserName + ', \n\n';
                    WhatsappMsg += 'Your Leave Request From : '+Mdate+' To : '+Mdate1+' is : *Approved*.  \n';
                    WhatsappMsg += ' Have a great day ahead!  ';

                    // WhatsappIntegration.sendMessage(MobileNO, UserName , WhatsappMsg);

                    if (String.isNotBlank(slackIdofApplyer)) {	
                        SlackIntegration.sendSlackMessage(WhatsappMsg, slackIdofApplyer);	
                    }

                    return ConEmail;
                }
                if(MailDetail.Status__c == 'Rejected'){
                    String bodygmail = 'Hi '+ConNm+', <br/> <br/>';
                    bodygmail += ' I hope you are doing well! <br /><br />';
                    bodygmail += 'I have received your request for leave from <b>'+ Mdate + '</b> to <b>' + Mdate1 + '</b> This notification serves as confirmation that your request for leave has been <b>Rejected</b>. <br /><br />';
                    bodygmail += 'Have a great day ahead! <br /><br />';
                    bodygmail += 'Thanks and regards,<br /><br />';
                    bodygmail += 'MV Team';
                    system.debug('Trainee Email id : ' + ConEmail);
                    sendGmail('Leave Status', bodygmail, ConEmail);

                    String UserName = ConNm;
                    String WhatsappMsg = '';
                    WhatsappMsg += 'Hi ' + UserName + ', \n\n';
                    WhatsappMsg += 'Your Leave Request From : '+Mdate+' To : '+Mdate1+' is : *Rejected*.  ';
                    WhatsappMsg += ' Please check the Status of your Leave  ';
                    
                    // WhatsappIntegration.sendMessage(MobileNO, UserName , WhatsappMsg);

                    if (String.isNotBlank(slackIdofApplyer)) {	
                        SlackIntegration.sendSlackMessage(WhatsappMsg, slackIdofApplyer);	
                    }

                    return ConEmail;
                }
            }
            system.debug('Trainee Email id2');
            return null;
            
        } catch(Exception e){
            System.debug('Exception->' + e.getMessage());
            return e.getMessage();
        }
    }

    public static string SendWhatsapp(List<Leave__c> SendMailDetail){
        for(Leave__c MailDetail : SendMailDetail){
            if(MailDetail.Status__c == 'Approved' || MailDetail.Status__c == 'Rejected' ){
                System.debug('In WP Method');
                String UserName = ' ';
                WhatsappIntegration.sendMessage('919499797187',UserName, MailDetail.Status__c);
            }
        }
        return 'Success';
    }
    
    @AuraEnabled
    public static List<Leave__c> allLeavesListForMentor(String LeavesStatus, Integer Months, Integer years, String Trainee){
        try {
            List<Leave__c> allLeaves = new List<Leave__c>();
            String query = 'SELECT Id, Name, Day__c, Reason__c, Contact_Trainee__c, Contact_Trainee__r.Name, Status__c, Leave_Type__c, Mentor__c FROM Leave__c';
            if(Trainee != 'All'){
                query += ' WHERE Contact_Trainee__c = \'' + Trainee + '\'';
            }

            // If we want to add leave status
            // if(!query.contains(' WHERE ')){
            //     query += ' WHERE Status__c = \'' + LeavesStatus + '\'';
            // } else {
            //     query += ' AND Status__c = \'' + LeavesStatus + '\'';
            // }

            if (Months != 0 || years != 0000){
                if(!query.contains(' WHERE ')){
                    query += ' WHERE ';
                } else {
                    query += ' AND ';
                }
                if(Months != 0 && years != 0000){
                    query += 'CALENDAR_MONTH(Start_Date__c) = ' + Months + ' AND CALENDAR_YEAR(Start_Date__c) = ' + years;
                } else if (Months != 0 && years == 0000){
                    query += 'CALENDAR_MONTH(Start_Date__c) = ' + Months;
                } else if (Months == 0 && years != 0000){
                    query += 'CALENDAR_YEAR(Start_Date__c) = ' + years;
                }
            }
            query += ' ORDER BY Name DESC';

            allLeaves = database.query(query);
            System.debug('allLeaves ==>' + allLeaves);
            return allLeaves;
        } catch (Exception e) {
            System.debug('exception ==> '+e.getStackTraceString() + ' || '+e.getMessage()); 
            return null;
        }
    }

    @AuraEnabled
    public static List<Contact> getTrainneList (){


        List<Leave__c> leaves = [SELECT Id, Name, Contact_Trainee__c FROM Leave__c];
        Set<Id> conId = new Set<Id>();
        for(Leave__c tsd : leaves){
            conId.add(tsd.Contact_Trainee__c);
        }
        List<Contact> contactlist = [SELECT Id, Name FROM Contact WHERE Id IN : conId ];
        System.debug('contactlist>>>'+contactlist);
        return contactlist;
    }

    @AuraEnabled
    public static List<Contact> displayTrainee (String trn){
        List<Contact> contactlist = [SELECT Id, Name FROM Contact ];
        return contactlist;
    }
}