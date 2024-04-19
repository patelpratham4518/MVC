public class SendEmailIfFail {
    @InvocableMethod
    public static void sendEmail(List<Interview__c> interviewees){
        Id ids = interviewees[0].Id;

        Interview__c interviewDetails = [SELECT Id, Date__c, Job_Posting__r.Job_Name__c,Interview_DateTime__c, Reporting_Date__c,Time__c, Result__c, Interviewer__c, Interviewer__r.Name ,Interviewer__r.Email__c ,  Interviewer_Email__c,  RecordType.Name, Job_Application__c, Job_Application__r.Job_Posting__c, Job_Application__r.Job_Posting__r.Job_Name__c, Job_Application__r.Contact__r.FirstName, Job_Application__r.Contact__r.LastName, Job_Application__r.Contact__r.Name, Job_Application__r.Contact__r.Email from Interview__c Where Id =:ids LIMIT 1];

        
    //     String subjectGmail = 'Interview Status';
    //     // String bodyGmail = 'Dear '+ConObj.FirstName+',<br /><br />Thank you for Registration.<br />A representative will contact you shortly.<br /><br />Best always,<br />MV Clouds<br /><br /><a href="https://mvclouds.com">Mv Clouds</a>';
    //     //String bodyGmail = '<p style="font-family:verdana !important;">Dear '+interviewees[0].Contact_FirstName__c+',<br /><br />'+
            
    //     String bodyGmail = '<p style="font-family:verdana">'+
    //             	'Dear '+interviewees[0].Contact_FirstName__c+','+
    //                 '<br /><br/>'+                    
    //                 'Thank you very much for investing your time and effort to interview with our team about our Salesforce developer position at MV Clouds Private Limited. '+
    //                 '<br /><br />'+
    //                 'All of us really enjoyed meeting you, learning about your skills and experiences and having a really interesting conversation. Unfortunately, at this time, we decided to proceed with our selection process with another candidate. We will definitely keep your resume in our talent database, and in case that we have a job opening that better fits your profile, we will make sure to get in touch with you. If you have any further questions or need more feedback, please do not hesitate to ask. I will be more than happy to answer any of your questions.'+
    //                 '<br /><br />'+
    //                 'I wish you the best of luck in your future endeavours and hope we\'ll have a chance to meet again soon.'+
    //                 '<br /><br />'+
    //                 'Regards,'+
    //                 '</p>';
        
    //     String sendTo = interviewees[0].Contact_FirstName__c + '<'+ interviewees[0].Contact_Email__c +'>';
        
    //     GoogleGmailApi.sendGmail(subjectGmail,bodyGmail,sendTo);
        
        
    // }
     if(interviewDetails.Result__c == 'Failed'){

        EmailTemplate emailtemplate1= [SELECT Id, Subject,Description,name,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE Name ='Your application status'];

            String subjectGmail = 'Your application status';
            
            String bodyGmail=emailtemplate1.HtmlValue;
            System.debug('bodyGmail::'+bodyGmail);
            bodyGmail=bodyGmail.replace('{!Contact.Name}', interviewDetails.Job_Application__r.Contact__r.FirstName);
            bodyGmail=bodyGmail.replace('{!Job_Posting__c.Job_Name__c}', interviewDetails.Job_Application__r.Job_Posting__r.Job_Name__c);
            System.debug('bodyGmail::'+bodyGmail);
            
            String sendTo = interviewDetails.Job_Application__r.Contact__r.Name + '<'+ interviewDetails.Job_Application__r.Contact__r.Email +'>'; // + ',' + 'Naimish Kalena<naimish.k@mvclouds.com>';
            // System.debug(sendTo);
            GoogleGmailApi.sendGmail(subjectGmail,bodyGmail,sendTo);    
        }
}

}