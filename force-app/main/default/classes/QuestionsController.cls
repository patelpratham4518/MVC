public without sharing class QuestionsController {

    @AuraEnabled 
    public static Account getAccount(String accountId){
        List <Account> accList = [SELECT Id, Name, Active__c FROM Account WHERE Id=:accountId LIMIT 1];
        if (accList.size() > 0) {
            return accList[0];
        }
        return null;
    }

    @AuraEnabled
    public static string createContact(String contactId, string firstname, string lastname, string email, string enroll, string mobile, string department, string semester, string gender, string resume, string accId, Boolean sendMailBool){
        string conId = '';
        string message = '';
        
        //check if contact already exist with same email as well as enrollment number
        List <Contact> conList = [SELECT Id, FirstName, LastName,Email, Enrollment_No__c FROM Contact WHERE Enrollment_No__c=:enroll LIMIT 1];

        //get college details
        Account acc = [SELECT Id, Name, Registration_Email_Template__c FROM Account WHERE Id=:accId];

        if(conList.size() > 0){
            conId = conList[0].Id;
            message = conList[0].Id;
            message += ' We already had contact with this enrollment with email '+conList[0].Email + ' and enrollment number '+conList[0].Enrollment_No__c;
        }else{
            Contact con = new Contact();
            if (contactId != null) {
                con.Id = contactId;
            }
            con.FirstName = firstname;
            con.LastName = lastname;
            con.Email = email;
            con.Enrollment_No__c = enroll;
            con.MobilePhone = mobile;
            con.Department = department;
            con.Semester__c = semester;
            con.Gender__c = gender;
            con.Apply_through_form__c = true;
            con.College_Name__c = acc.Name;
            upsert con;

            conId = con.Id;
            message = con.Id;
            message += ' New Contact Created with enrollment number '+con.Enrollment_No__c +' and email '+con.Email;
            if (sendMailBool) {
                sendEmail(con.Id);
            } else{
                sendRegisterEmail(con, acc.Registration_Email_Template__c);
            }
            if(resume != null && resume != ''){
                Attachment attachment = new Attachment();
                attachment.Name = enroll + ' Resume.pdf';
                attachment.Body = EncodingUtil.base64Decode(resume);
                attachment.ParentId = con.Id;
                insert attachment;
            }
        }
        
        // GoogleGmailApi.sendGmail('subjectGmail','bodyGmail','jaimin.s@mvclouds.com');
        return message;
    }

    //Send Mail using Gmail API
    @AuraEnabled
    public static void sendEmail(string conId){

        Contact Con = [SELECT Id, FirstName, LastName, Email, Enrollment_No__c FROM Contact WHERE Id=:conId LIMIT 1];

        String subjectGmail = 'MV Clouds - Unique Link to start your test';
        String bodyGmail = 'Dear ' + Con.FirstName;
        bodyGmail += ',<br/><br/>Please find below the link for ' + Con.Enrollment_No__c + ' to start your online test.<br/><br/>';
        bodyGmail += '<a href="https://dharmikmv-dev-ed.my.salesforce-sites.com/questions?conId='+Con.Id+'">https://dharmikmv-dev-ed.my.salesforce-sites.com/questions?conId='+Con.Id+'</a><br/><br/>';
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
        String sendTo = Con.Email;
        GoogleGmailApi.sendGmail(subjectGmail,bodyGmail,sendTo);
    }

    //Send Mail using Gmail API
    @AuraEnabled
    public static void sendRegisterEmail(Contact Con, String registrationEmailTemplate){
        String subjectGmail = 'MV Clouds - Placement Registration';

        String emailTemplpate = registrationEmailTemplate;
        emailTemplpate = emailTemplpate.replace('{!Contact.FirstName}' , con.FirstName);
        emailTemplpate = emailTemplpate.replace('{!Contact.Email}' , con.Email);

        GoogleGmailApi.sendGmail(subjectGmail, emailTemplpate, con.Email);
    }

    @AuraEnabled
    public static Contact getContact(String contactId){
        Contact con = [SELECT Id, FirstName, LastName, Name, Email, Enrollment_No__c, MobilePhone, Department, Semester__c, Exam_Submitted__c, Account.Id, Account.Name, Account.Exam_Date_Time__c FROM Contact WHERE Id=:contactId];
        return con;
    }

    @AuraEnabled
    public static List<Question__c> getAptitudeQuestions(){
        List<Question__c> qustionList = [SELECT Id, Type__c, Question__c, Aptitude_Options__c, Aptitude_Answer__c, Aptitude_Options_Count__c FROM Question__c WHERE Type__c = 'Aptitude'];
        return qustionList;
    }

    @AuraEnabled
    public static Answer__c getAnswerData(String conId){
        List<Answer__c> ansList = [SELECT Id, Name, Question_1__c, Question_2__c, Question_3__c, Question_4__c, Question_5__c, Question_6__c, Aptitude_Data__c, 
                                    Answer_1__c, Answer_2__c, Answer_3__c, Answer_4__c, Answer_5__c, Answer_6__c, Language_Type__c, Contact__c, Aptitude_Marks__c FROM Answer__c WHERE Contact__c =: conId LIMIT 1];
        Answer__c answer = new Answer__c();
        if (ansList.size() > 0) {
            answer = ansList[0];
        } else {
            answer.Contact__c = conId;
            insert answer;
        }
        return answer;
    }

    @AuraEnabled
    public static void saveAptitudeResult(String ansId, Integer aptitudeMarks){
        Answer__c answer = [SELECT Id, Name, Aptitude_Data__c, Aptitude_Marks__c FROM Answer__c WHERE Id =: ansId];
        answer.Aptitude_Marks__c = aptitudeMarks;

        Integer passingMarks = Integer.ValueOf(System.Label.Aptitude_Passing_Marks);
        if (answer.Aptitude_Marks__c > passingMarks) {
            answer.Aptitude_Result__c = 'Pass';
        } else {
            answer.Aptitude_Result__c = 'Fail';
        }
        
        update answer;
    }

    @AuraEnabled
    public static void updateAnsRec(String ansId, String aptData){
        Answer__c answer = [SELECT Id, Name, Aptitude_Data__c, Aptitude_Marks__c FROM Answer__c WHERE Id =: ansId];
        answer.Aptitude_Data__c = aptData;
        update answer;
    }

    @AuraEnabled
    public static List<Question__c> getQuestions(List<String> langlist, String ansId){
        Answer__c ans = [SELECT Id, Name, Question_1__c, Question_2__c, Question_3__c, Question_4__c, Question_5__c, Question_6__c, Aptitude_Data__c, Aptitude_Marks__c, Contact__c, Language_Type__c FROM Answer__c WHERE Id =: ansId];
        
        List<Question__c> queList = new List<Question__c>();
        if (ans.Question_1__c != null && ans.Language_Type__c != null) {
            Set<Id> queIds =  new Set<id>();
            queIds.add(ans.Question_1__c);
            queIds.add(ans.Question_2__c);
            queIds.add(ans.Question_3__c);
            queIds.add(ans.Question_4__c);
            queIds.add(ans.Question_5__c);
            queIds.add(ans.Question_6__c);
            queList = [SELECT Id, Name, Type__c, Question__c FROM Question__c WHERE Id =: queIds];
        } else {
            List<Question__c> queList1 = [SELECT Id, Name, Type__c, Question__c FROM Question__c WHERE Type__c =: langlist[0]];
            List<Question__c> queList2 = [SELECT Id, Name, Type__c, Question__c FROM Question__c WHERE Type__c =: langlist[1]];

            if (queList1.size() > 2 && queList2.size() > 2) {
                while (queList.size() < 3){
                    Integer index = (Math.random() * (queList1.size() - 1)).intValue();
                    System.debug('index ==> '+index);
                    System.debug('queList.size() ==> '+queList.size());
                    queList.add(queList1.remove(index));
                }
                while (queList.size() < 6){
                    Integer index = (Math.random() * (queList2.size() - 1)).intValue();
                    System.debug('index ==> '+index);
                    System.debug('queList.size() ==> '+queList.size());
                    queList.add(queList2.remove(index));
                }
    
                String lanStr = string.join(langlist,'###');
                ans.Question_1__c = queList[0].Id;
                ans.Question_2__c = queList[1].Id;
                ans.Question_3__c = queList[2].Id;
                ans.Question_4__c = queList[3].Id;
                ans.Question_5__c = queList[4].Id;
                ans.Question_6__c = queList[5].Id;
                ans.Language_Type__c = lanStr;
                update ans;
            }

        }
        return queList;
    }

    @AuraEnabled
    public static Answer__c saveSingleAnswer(String ansRecId, String queId, String answerData){
        Answer__c answer = [SELECT Id, Name, Answer_1__c, Answer_2__c, Answer_3__c, Answer_4__c, Answer_5__c, Answer_6__c, 
                            Question_1__c, Question_2__c, Question_3__c, Question_4__c, Question_5__c, Question_6__c, Contact__c FROM Answer__c WHERE Id =: ansRecId];

        if (answer.Question_1__c == queId) {
            answer.Answer_1__c = answerData;
        } else if (answer.Question_2__c == queId) {
            answer.Answer_2__c = answerData;
        } else if (answer.Question_3__c == queId) {
            answer.Answer_3__c = answerData;
        } else if (answer.Question_4__c == queId) {
            answer.Answer_4__c = answerData;
        } else if (answer.Question_5__c == queId) {
            answer.Answer_5__c = answerData;
        } else if (answer.Question_6__c == queId) {
            answer.Answer_6__c = answerData;
        }

        update answer;
        return answer;
    }

    @AuraEnabled
    public static void saveAnswers(Answer__c answer){
        System.debug('answer ==> '+answer);
        update answer;
        
        Answer__c ans = [SELECT Id, Name, Answer_1__c, Answer_2__c, Answer_3__c, Answer_4__c, Answer_5__c, Answer_6__c, 
                            Question_1__c, Question_2__c, Question_3__c, Question_4__c, Question_5__c, Question_6__c, 
                            Question_1__r.Question__c, Question_2__r.Question__c, Question_3__r.Question__c, Question_4__r.Question__c, 
                            Question_5__r.Question__c, Question_6__r.Question__c, Language_Type__c, Contact__c FROM Answer__c WHERE Id =: answer.Id];

        String conId = ans.Contact__c;
        Contact con = [SELECT Id, Name, Email, Exam_Submitted__c FROM Contact WHERE Id =: conId];
        con.Exam_Submitted__c = true;
        update con;

        EmailTemplate emailTemplate = [Select Id,Subject,HtmlValue,Body from EmailTemplate where name = 'thank you'];

        String sendTo = con.Name+'<'+con.Email+'>';
        String subject = emailTemplate.Subject;
        String htmlBody = emailTemplate.HtmlValue;
        String body = htmlBody.replace( '{!Contact.Name}', con.Name );
        GoogleGmailApi.sendGmail(subject,body,sendTo);

    }
    
    public static void forceSubmit(String accId){

        String collegeName;
        List<Account> college = [SELECT Id, Name FROM Account WHERE Id =: accId LIMIT 1];
        if (college.size() > 0) {
            collegeName = college[0].Name;
        }

        if (collegeName != null) {
            List<Contact> contactList = [SELECT Id, Name, Email, Description, Enrollment_No__c, College_Name__c, Apply_through_form__c, Exam_Submitted__c FROM Contact WHERE Apply_through_form__c = true AND Enrollment_No__c != Null AND College_Name__c =: collegeName AND Exam_Submitted__c = false];
            System.debug('contactList ==> '+contactList.size());
            if (contactList.size() > 0) {
                for (Contact con : contactList) {
                    con.Exam_Submitted__c = true;
                    con.Description = 'Force Submit';
                }
                // update contactList;
            }
        }

    }

}