public without Sharing class InterviewResultController {

    @AuraEnabled(cacheable=true)
    public static List<Account> getCollege(){
        List<Account> collList = [SELECT Id, Name, RecordType.Name FROM Account WHERE RecordType.Name = 'College'];
        return collList;
    }
    
    @AuraEnabled
    public static List<Contact> getContact(String collegeName) {

        if (collegeName == 'ALL') {
            return [SELECT Id, Name, Email, Description, Enrollment_No__c, College_Name__c, Apply_through_form__c, 
                (SELECT Id, Name, Aptitude_Marks__c, Aptitude_Result__c, Practical_Result__c, Answer_1__c, Answer_2__c, Answer_3__c, Answer_4__c, Answer_5__c, Answer_6__c FROM Answers__r) 
                FROM Contact 
                WHERE Apply_through_form__c = true AND Enrollment_No__c != Null];
        }else{
            return [SELECT Id, Name, Email, Description, Enrollment_No__c, College_Name__c, Apply_through_form__c, 
                (SELECT Id, Name, Aptitude_Marks__c, Aptitude_Result__c, Practical_Result__c, Answer_1__c, Answer_2__c, Answer_3__c, Answer_4__c, Answer_5__c, Answer_6__c FROM Answers__r) 
                FROM Contact 
                WHERE Apply_through_form__c = true AND Enrollment_No__c != Null AND College_Name__c = :collegeName];
        }
    }

    @AuraEnabled
    public static Answer__C getAnswer(String contId){
        Answer__C ans = [SELECT Id, Practical_Result__c, Answer_1__c, Answer_2__c, Answer_3__c, Answer_4__c, Answer_5__c, Answer_6__c, Aptitude_Marks__c, Aptitude_Data__c, Question_1__r.Question__c, Question_2__r.Question__c, Question_3__r.Question__c, Question_4__r.Question__c, Question_5__r.Question__c, Question_6__r.Question__c, Contact__c, Contact__r.Name, Contact__r.Enrollment_No__c  FROM Answer__c WHERE Contact__c =: contId LIMIT 1];
        return ans;
    }

    @AuraEnabled
    public static List<Contact> updateResult(String answerId, String resultval, String collegeName){
        Answer__c ans = [SELECT Id, Practical_Result__c, Contact__c FROM Answer__c WHERE Id =: answerId LIMIT 1];
        ans.Practical_Result__c = resultval;
        update ans;

        if (resultval == 'Pass') {
            List<Job_Application__c> jobApplications = [SELECT Id, Name, Contact__c FROM Job_Application__c WHERE Contact__c =: ans.Contact__c];
            List<Job_Posting__c> jobPostList = [SELECT Id, Name FROM Job_Posting__c WHERE Job_Name__c = 'Salesforce Internship'];

            if (jobApplications.size() == 0 && jobPostList.size() > 0) {
                Job_Application__c jobApp = new Job_Application__c();
                jobApp.Contact__c = ans.Contact__c;
                jobApp.Job_Posting__c = jobPostList[0].Id;
                insert jobApp;
            }
        }

        return getContact(collegeName);
    }

    // for update aptirude result accouring to new custom label data.
    public static void updateAptitudeResult(){
        list<Answer__c> ansList = [SELECT Id, Name, Aptitude_Data__c, Aptitude_Marks__c , Aptitude_Result__c, Contact__c, Contact__r.Name  FROM Answer__c WHERE createddate >= LAST_N_DAYS:5 AND Aptitude_Marks__c != NULL];
        Integer passingMarks = Integer.ValueOf(System.Label.Aptitude_Passing_Marks);
        
        for (Answer__c ans : ansList) {
            if (ans.Aptitude_Marks__c > passingMarks) {
                ans.Aptitude_Result__c = 'Pass';
            } else {
                ans.Aptitude_Result__c = 'Fail';
            }
        }

        if (ansList.size() > 0) {
            update ansList;
        }
    }
}