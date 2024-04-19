public class AssetDemo {
    
    
    @AuraEnabled
    public static List<ContantDoc> getContents(Id jobID, Integer fatchedRecordNo) {
        System.debug('jobID'+jobID);
        Map<Id, ContantDoc> ContactDocumentMap = new Map<Id,ContantDoc>();
        
        for(ContentDocumentLink cdl : [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: jobID ORDER BY Id DESC LIMIT 1]){
            ContactDocumentMap.put(cdl.ContentDocumentId, new ContantDoc(null, cdl.ContentDocumentId));
        }
        
        Map<Id, ContentVersion> ContentVersionMap = new Map<Id,ContentVersion>([SELECT Id,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN : ContactDocumentMap.keySet()]);
        
        
        System.debug(ContactDocumentMap);
        return ContactDocumentMap.values();
    }
    public class ContantDoc {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String fileId;
        
        public ContantDoc(String Name, String fileId){
            this.name = Name;
            this.fileId = fileId;
            
        }
    }
    
    @AuraEnabled
    public static Attachment testw(String jid){
        Attachment ase = new Attachment();
        ase = [SELECT Id,Name,Body FROM Attachment WHERE ParentId =: jid ];
        
        return ase;
    }
}