/***************************************************************
Created by : Harsh Gandhi 
Use : Send Email with CSV of student who appeared in Exam
Last modified by-date: 29/12/2023 - Harsh
***************************************************************/
public class AutoSubmitExamAndSendDataBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful, Schedulable {
    public String collegeName;
    public String collegeId;
    public String csvContent;
    public String queryAttr = 'FirstName,LastName,Email,Phone,Enrollment_No__c,Semester__c,Gender__c'; // Add contact field to fetch with comma seperated without whitespace

    // store accountId
    public AutoSubmitExamAndSendDataBatch(String accId){
        List<Account> college = [SELECT Id, Name, Exam_Date_Time__c FROM Account WHERE Id =: accId LIMIT 1];
        if (!college.isEmpty()) {
            collegeName = college[0].Name;
            collegeId = college[0].Id;
        }
    }

    // get studentList from accountId's Name (College name) 
    public Iterable<sObject> start(Database.BatchableContext info){
        List<Contact> studentList = new List<Contact>();
        if (collegeName != null) {
            String studentQuery = 'SELECT ' + queryAttr + ' FROM Contact WHERE College_Name__c =: collegeName AND Exam_Submitted__c != true AND CreatedDate = THIS_YEAR';
            studentList = Database.query(studentQuery);
        }
        return studentList;
    }

    // prepare CSV content and update Exam_Submitted__c checkbox
    public void execute(Database.BatchableContext info, List<Contact> studentList){
        csvContent = queryAttr+'\n';                                // CSV header
        List<String> fieldList = queryAttr.split(',');
        for(Contact con : studentList){
            for (Integer i = 0; i < fieldList.size(); i++) {
                String field = fieldList[i];
                
                // Get the field value dynamically using SObject get method
                Object fieldValue = con.get(field);
                csvContent += String.valueOf(fieldValue);                   // CSV row values
        
                // Append a comma if it's not the last field
                if (i < fieldList.size() - 1) {
                    csvContent += ',';
                }
            }
            csvContent += '\n';
            con.Exam_Submitted__c = true;
        }
        update studentList;
    }
    
    // Send Email with CSV attachment of list of student
    public void finish(Database.BatchableContext info){
        if (csvContent != null) {      
            String sendTo = System.Label.HR_Email;                   // Send email to multiple receipients by adding comma seperated emailss
            String emailSubject = collegeName + ' Exam Data';                               // Subject of Email
            
            // Prepare the attachment
            Blob csvBlob = Blob.valueOf(csvContent);
            String csvData = EncodingUtil.base64Encode(csvBlob);
            String csvName = emailSubject + '.csv';

            String boundary = 'boundary_string';
            String contentType = 'multipart/mixed; boundary="' + boundary + '"';
            String emailContent = '--' + boundary + '\n' +
                                'Content-Type: text/plain; charset="UTF-8"\n\n' +
                                'Few students is not attend exam. Student list attached below.\n\n' +
                                '--' + boundary + '\n' +
                                'Content-Disposition: attachment; filename="' + csvName + '"\n' +
                                'Content-Type: text/csv; charset="UTF-8"; name="' + csvName + '"\n' +
                                'Content-Transfer-Encoding: base64\n\n' +
                                csvData + '\n\n' + 
                                '--' + boundary + '--\n';

            String response = Gmail_Integration.sendEmail(sendTo, emailSubject, contentType, emailContent);

            if (response.contains('Error')) {
                String emailBody = 'AutoSubmitExamAndSendDataBatch finish method failed for send all contact data CSV to HR.\n' + response;
                Gmail_Integration.sendEmail(sendTo, 'AutoSubmitExamAndSendDataBatch Failed', 'text/html', emailBody);
                System.debug('Error Email ==> '+emailBody);
            }

            Account college = [SELECT Id, Name, Active__c, Exam_Date_Time__c FROM Account WHERE Id =: collegeId];
            college.Active__c = false;
            college.Exam_Date_Time__c = null;
            update college;
        }
    }

    public void execute(SchedulableContext ctx) {
        AutoSubmitExamAndSendDataBatch autoSubmit = new AutoSubmitExamAndSendDataBatch(collegeId);
        Database.executeBatch(autoSubmit);
    }
}