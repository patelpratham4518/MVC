public class scheduleInterviewController {

    @AuraEnabled
    public static Job_Application__c getJobApplication(Id contactId) {
        List<Job_Application__c> jobApplications = [SELECT Id, Contact__c, Job_Posting__c FROM Job_Application__c WHERE Contact__c = :contactId LIMIT 1];
        if (jobApplications.size() == 1) {
            return jobApplications[0];
        }
        return null;
    }

    @AuraEnabled
    public static Interview__c createInterviewRecord(Id jobApplicationId, Id contactId, Id jobPostingId, Boolean meetingLink, String roundName, Id interviewerId, String TimeOfInterview, Date DateofInterview) {
        String[] timeParts = TimeOfInterview.split(':');
        Integer hour = Integer.valueOf(timeParts[0]);
        Integer minute = Integer.valueOf(timeParts[1]);
        Time interviewTime = Time.newInstance(hour, minute, 0,0);

        Interview__c interviewRecord = new Interview__c();
        interviewRecord.Job_Application__c = jobApplicationId;
        interviewRecord.Contact__c = contactId;
        interviewRecord.Job_Posting__c = jobPostingId;
        interviewRecord.Meeting_Link__c = meetingLink;
        interviewRecord.Interview_Round_Name__c = roundName;
        interviewRecord.Interviewer__c = interviewerId;
        interviewRecord.Time__c = interviewTime;
        interviewRecord.Date__c = DateofInterview;
        insert interviewRecord;

        return interviewRecord;
    }

}