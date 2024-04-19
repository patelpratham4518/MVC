public without sharing class CourseController {

    @AuraEnabled
    public static List<Event__c>  getEvents(){
      try {
        List<Event__c> evnt = [Select id , Name , Image__c , Description__c	, Date__c	From Event__c ];
        return evnt;
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
    }
    
}