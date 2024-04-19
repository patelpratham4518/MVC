public class democlass {
    public List<Credential__c> listc {get;set;}
    public democlass(){
        
        List<Credential__c> listc = new List<Credential__c>();
        
        listc = [Select id, rd__c, Username__c From Credential__c];
        System.debug(listc);
    }
}