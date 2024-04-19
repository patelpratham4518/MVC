public without sharing  class TraineeController {

    @AuraEnabled
    public static List<Contact> gettraineelist(){
        try {

            Id contactid = [SELECT Name, ContactId FROM User WHERE Id =: UserInfo.getUserId()].ContactId;
            Id teamid = [SELECT Id, Name, Team__c FROM Contact WHERE Id =: contactid].Team__c;
            return [SELECT Id, Name, Email, Phone, Team__c FROM Contact WHERE Id !=: contactid AND Team__c =: teamid];

        } catch(Exception e) {
            System.debug('Exception ==>'+e.getMessage());
            return null;
        }
    }
        

}