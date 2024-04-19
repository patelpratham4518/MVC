public class CollegeController {
    
    @AuraEnabled
    public static List<Account> getColleges() {
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE Name = 'College' LIMIT 1];
        List<Account> acc =[SELECT Id, Name, Active__c ,RecordTypeId, Exam_Link_Template__c, Exam_Reminder_Template__c, Registration_Email_Template__c, Exam_Date_Time__c FROM Account WHERE RecordTypeId =:rt.Id];
        List<EmailTemplate> template = [SELECT Id, Name, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE name = 'Successful Registration' OR name = 'Exam Reminder' OR name = 'Exam Link Template'];
        Map<String, EmailTemplate> mapTemp = new Map<String, EmailTemplate>();

        for (EmailTemplate tmp : template) {
            mapTemp.put(tmp.Name, tmp);
        }
        
        for (Account a : acc) {
            a.Registration_Email_Template__c = mapTemp.get('Successful registration').HtmlValue;
            a.Exam_Link_Template__c = mapTemp.get('Exam Link Template').HtmlValue;
            a.Exam_Reminder_Template__c = mapTemp.get('Exam reminder').HtmlValue;
        }
        return acc;
    }

    @AuraEnabled
    public static List<Account> createCollege(String name) {
        RecordType recordtype = [SELECT Id, Name FROM RecordType WHERE Name = 'College' LIMIT 1];
        Account newCollege = new Account(
            Name = name,
            RecordTypeId = recordtype.Id
        );

        insert newCollege;
        List<Account> alist = getColleges();
        return alist;
    }

    @AuraEnabled
    public static List<Account> deleteCollege(String collegeid) {
        List<Account> collegesToDelete = [SELECT Id, Name FROM Account WHERE Id = :collegeid LIMIT 1];
        delete collegesToDelete;
        
        List<Account> alist = getColleges();
        return alist;
    }

    @AuraEnabled
    public static List<Contact> getStudents(String collegeId){
        Account college = [SELECT Id, Name, Exam_Reminder_Template__c FROM Account WHERE Id =: collegeId];
        List<Contact> contacts = new List<Contact>();
        contacts = [SELECT Id, FullName__c, Enrollment_No__c, Email, MobilePhone, Semester__c FROM Contact WHERE College_Name__c =: college.Name AND CreatedDate = THIS_YEAR];
        return contacts;
    }

    @AuraEnabled
    public static string updateAccount(String accId, long dtime, string registerEmail, string reminderEmail, string examLink){
        Datetime dt = DateTime.newInstance(dtime);
        Account acc = [SELECT Id, Name, Exam_Link_Template__c, Exam_Reminder_Template__c, Registration_Email_Template__c, Exam_Date_Time__c, Active__c FROM Account WHERE Id = : accId];
        acc.Registration_Email_Template__c = registerEmail; 
        acc.Exam_Reminder_Template__c = reminderEmail;
        acc.Exam_Link_Template__c = examLink;
        acc.Exam_Date_Time__c = dt;
        acc.Active__c = true;

        DateTime reminderTime = dt.addHours(-20);
        DateTime examLinkTime = dt.addHours(-1);
        DateTime examSubmitTime = dt.addHours(+2);
        examSubmitTime = examSubmitTime.addMinutes(1);

        // Scheduling class
        String reminderCron = reminderTime.second() + ' ' + reminderTime.minute() + ' ' + reminderTime.hour() + ' ' + reminderTime.day() + ' ' + reminderTime.month() + ' ? ' + reminderTime.year() + ' ';
        System.schedule('Reminder link for ' + acc.Name, reminderCron, new sendExamReminderScheduleBatch(accId));

        String examCron = examLinkTime.second() + ' ' + examLinkTime.minute() + ' ' + examLinkTime.hour() + ' ' + examLinkTime.day() + ' ' + examLinkTime.month() + ' ? ' + examLinkTime.year() + ' ';
        System.schedule('Exam Link for ' + acc.Name, examCron, new sendExamLinkScheduleBatch(accId));

        String submitCron = examSubmitTime.second() + ' ' + examSubmitTime.minute() + ' ' + examSubmitTime.hour() + ' ' + examSubmitTime.day() + ' ' + examSubmitTime.month() + ' ? ' + examSubmitTime.year() + ' ';
        System.schedule('Auto Submit Exam for ' + acc.Name, submitCron, new AutoSubmitExamAndSendDataBatch(accId));

        update acc;
        return 'Success';
    }
    
    @AuraEnabled
    public static string sendEmail(String email, String subject ,String body){
        String response = Gmail_Integration.sendEmail(email, subject, 'text/html', body);
        return response;
    }
}