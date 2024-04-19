public with sharing class sendExamLinkScheduleBatch implements Database.Batchable<Contact>, Database.AllowsCallouts, Database.Stateful, Schedulable {
    public String collegeName;
    public String collegeId;
    public String examLinkTemplate;

    public sendExamLinkScheduleBatch(String accId) {
        List<Account> college = [SELECT Id, Name, Exam_Link_Template__c FROM Account WHERE Id =: accId LIMIT 1];
        if (!college.isEmpty()) {
            collegeName = college[0].Name;
            collegeId = college[0].Id;
            examLinkTemplate = college[0].Exam_Link_Template__c;
        }
    }
      
    public List<Contact> start(Database.BatchableContext info){ 
        List<Contact> studentList = new List<Contact>();
        if (collegeName != null) {
            studentList = [SELECT Id, FirstName, LastName, Email, Enrollment_No__c FROM Contact WHERE College_Name__c =: collegeName AND Exam_Submitted__c != true AND CreatedDate = THIS_YEAR];
        }
        return studentList; 
    }

    public void execute(Database.BatchableContext info, List<Contact> contactList){
        for(Contact con : contactList){ 
            String examLink =  System.Label.Site_URL + 'questions?conId=' + con.Id;

            String emailTemplpate = examLinkTemplate;
            emailTemplpate = emailTemplpate.replace('{!Contact.FirstName}', con.FirstName);
            emailTemplpate = emailTemplpate.replace('{!Contact.Enrollment_No__c}' , con.Enrollment_No__c);
            emailTemplpate = emailTemplpate.replace('{Exam_Link}', examLink);
    
            String response = Gmail_Integration.sendEmail(con.Email, 'MV Clouds - Exam Details', 'text/html', emailTemplpate);

            if (response.contains('Error')) {
                String emailBody = 'sendExamLinkScheduleBatch failed for ' + con.Id + ' contact id.\n' + response;
                Gmail_Integration.sendEmail(System.Label.HR_Email, 'sendExamLinkScheduleBatch Failed', 'text/html', emailBody);
                System.debug('Error Email ==> '+emailBody);
            }
        }
    }

    public void finish(Database.BatchableContext info){
        System.debug('sendExamLinkBatch Finish');
    }

    public void execute(SchedulableContext ctx){
        sendExamLinkScheduleBatch examLink = new sendExamLinkScheduleBatch(collegeId);
        Database.executeBatch(examLink);
    }

}