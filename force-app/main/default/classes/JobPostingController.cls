public without sharing class JobPostingController {
    @AuraEnabled
    public static List<Job_Posting__c> getposting(){
        
        List<Job_Posting__c> posting = [SELECT Id, Name, Job_Name__c, On_Off__c FROM Job_Posting__c WHERE On_Off__c = true];
        return posting;
    }
}