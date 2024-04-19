public class LeadStatusUpdate {
	 @AuraEnabled
    public static void updateStage(String leadStatus , String recordId){
        Lead l = [Select Id ,Status from Lead where Id=:recordId] ; 
        l.Status =leadStatus ; 
        update l ;   
    }
}