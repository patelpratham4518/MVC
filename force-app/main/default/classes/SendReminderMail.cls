public class SendReminderMail {
	@InvocableMethod
    public static void sendEmail(List<Interview__c> interviewees){
        System.debug(interviewees[0]);
        System.debug(interviewees[0].Id);
        Id ids = interviewees[0].Id;
        System.debug(ids);

        Interview__c interviewDetails = [SELECT Id, Date__c,Interview_DateTime__c, Time__c, Result__c, Interviewer__c, Interviewer__r.Name ,Interviewer__r.Email__c ,  Interviewer_Email__c,  RecordType.Name, Job_Application__c, Job_Application__r.Job_Posting__c, Job_Application__r.Job_Posting__r.Job_Name__c, Job_Application__r.Contact__r.FirstName, Job_Application__r.Contact__r.LastName, Job_Application__r.Contact__r.Name, Job_Application__r.Contact__r.Email,Interview_Round_Name__c from Interview__c Where Id =:ids LIMIT 1];
        System.debug('interviewDetails :: ' + interviewDetails);
        if(interviewDetails.Result__c == '' || interviewDetails.Result__c == null){
            String subjectGmail = 'Reminder Email';
            String bodyGmail1 = 'Hello '+
                interviewDetails.Interviewer__r.Name +','+ '<br/><br/>'+
                'I just want to remind you that you had taken an interview of ' +  
                '<a href="'+System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/Contact/'+interviewDetails.Job_Application__r.Contact__r.Id+'/view">'+interviewDetails.Job_Application__r.Contact__r.Name+'</a>' +
                + ' and did not update the result till now. <br/>'+
                'Please update the result of the candidate'+
                // '<a href="'+System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/Interview__c/'+interviewDetails.Id+'/view">'+interviewDetails.Interview_Round_Name__c +' round'+'</a>' +
                +' as soon as possible.<br/><br/>'+
                'To update the result '+ 
                '<a href="'+System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/Interview__c/'+interviewDetails.Id+'/view">'+ 'Click Here' +'</a>' +
                '<br/><br/>'+
                'Regards,';
            System.debug('bodyGmail1-------------->' + bodyGmail1);
                        
            String sendTo = interviewDetails.Interviewer__r.Name +  '<'+ interviewDetails.Interviewer__r.Email__c +'>';
            // String s1 = System.Label.DharmikShah_Email;
            // String sendTo1 = interviewDetails.Interviewer__r.Name +  '<'+ interviewDetails.Interviewer__r.Email__c +'>' + s1 ;
            System.debug(sendTo);
            GoogleGmailApi.sendGmail(subjectGmail,bodyGmail1,sendTo);
            // GoogleGmailApi.sendGmail(subjectGmail,bodyGmail1,sendTo1);
        }  
      }
}