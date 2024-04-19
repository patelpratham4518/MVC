public with sharing class sendExamReminderScheduleBatch implements Database.Batchable<Contact>, Database.AllowsCallouts, Database.Stateful, Schedulable{
    public String collegeName;
    public String collegeId;
    public String examReminderTemplate;
    public String queryAttr = 'FirstName,LastName,Email,Phone,Enrollment_No__c,Semester__c,Gender__c';  // Add contact field to fetch with comma seperated without whitespace

    public sendExamReminderScheduleBatch(String accId) {
        List<Account> college = [SELECT Id, Name, Exam_Reminder_Template__c FROM Account WHERE Id =: accId LIMIT 1];
        if (!college.isEmpty()) {
            collegeName = college[0].Name;
            collegeId = college[0].Id;
            examReminderTemplate = college[0].Exam_Reminder_Template__c;
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
            String emailTemplpate = examReminderTemplate;
            emailTemplpate = emailTemplpate.replace('{!Contact.FirstName}' , con.FirstName);

            String response = Gmail_Integration.sendEmail(con.Email, 'MV Clouds - Exam Reminder', 'text/html', emailTemplpate);
            
            if (response.contains('Error')) {
                String emailBody = 'sendExamReminderScheduleBatch failed for ' + con.Id + ' contact id.\n' + response;
                Gmail_Integration.sendEmail(System.Label.HR_Email, 'sendExamReminderScheduleBatch Failed', 'text/html', emailBody);
                System.debug('Error Email ==> '+emailBody);
            }
        }
    }

    public void finish(Database.BatchableContext info){
        System.debug('sendExamLinkBatch Finish');
        if (collegeName != null) {
            List<Contact> studentList = new List<Contact>();
            String studentQuery = 'SELECT ' + queryAttr + ' FROM Contact WHERE College_Name__c =: collegeName AND Exam_Submitted__c != true AND CreatedDate = THIS_YEAR';
            studentList = Database.query(studentQuery);

            String csvContent = queryAttr+'\n'; 
            List<String> fieldList = queryAttr.split(',');
            for(Contact con : studentList){
                for (Integer i = 0; i < fieldList.size(); i++) {
                    String field = fieldList[i];
                    Object fieldValue = con.get(field);
                    csvContent += String.valueOf(fieldValue);
                    if (i < fieldList.size() - 1) {
                        csvContent += ',';
                    }
                }
                csvContent += '\n';
            }

            String sendTo = System.Label.HR_Email;
            String emailSubject = collegeName + ' Student List';

            Blob csvBlob = Blob.valueOf(csvContent);
            String csvData = EncodingUtil.base64Encode(csvBlob);
            String csvName = emailSubject + '.csv';

            String boundary = 'boundary_string';
            String contentType = 'multipart/mixed; boundary="' + boundary + '"';
            String emailContent = '--' + boundary + '\n' +
                                'Content-Type: text/plain; charset="UTF-8"\n\n' +
                                'All registered student link under ' + collegeName + ' attach below.\n\n' +
                                '--' + boundary + '\n' +
                                'Content-Disposition: attachment; filename="' + csvName + '"\n' +
                                'Content-Type: text/csv; charset="UTF-8"; name="' + csvName + '"\n' +
                                'Content-Transfer-Encoding: base64\n\n' +
                                csvData + '\n\n' + 
                                '--' + boundary + '--\n';

            String response = Gmail_Integration.sendEmail(sendTo, emailSubject, contentType, emailContent);

            if (response.contains('Error')) {
                String emailBody = 'sendExamReminderScheduleBatch finish method failed for send all contact data CSV to HR.\n' + response;
                Gmail_Integration.sendEmail(sendTo, 'sendExamReminderScheduleBatch Failed', 'text/html', emailBody);
                System.debug('Error Email ==> '+emailBody);
            }
        }
    }

    public void execute(SchedulableContext ctx) {
        sendExamReminderScheduleBatch reminder = new sendExamReminderScheduleBatch(collegeId);
        Database.executeBatch(reminder);
    }

}