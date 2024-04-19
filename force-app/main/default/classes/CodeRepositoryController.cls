public with sharing class CodeRepositoryController {
     @AuraEnabled(cacheable=true)
    public static list<Code_Share__c> getCodeList() {

        try {
		
            // create Code_Share__c list to store search result 
                list<Code_Share__c> codeListRecord = new list<Code_Share__c>();

                codeListRecord = [SELECT Id,Description__c,Active__c,Category_Main_Primary__c,Category_Secondary__c,Name,Developer_name__c,Label__c,Number_of_files__c FROM Code_Share__c WHERE Active__c = true];

                System.debug('codeListRecord---->'+codeListRecord);
                
                return codeListRecord;
        } catch (Exception e) {
            System.debug('Error:-->'+ e.getMessage() + ' ' + e.getLineNumber());
            return null;
        }
        
    }

    @AuraEnabled
    public static Map<String, String> getPicklistLabelName(String picklistFieldAPIName){
        try {
                Map<String, String> picklistValuesWithLabels = new Map<String, String>();
                Schema.DescribeFieldResult fieldResult = Code_Share__c.getSObjectType().getDescribe().fields.getMap().get(picklistFieldAPIName).getDescribe();
                List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
                for (Schema.PicklistEntry entry : picklistEntries) {
                    picklistValuesWithLabels.put(entry.getValue(), entry.getLabel());
                }

                System.debug(picklistValuesWithLabels);
                return picklistValuesWithLabels;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<CodeFileWrapper> getCodeFileds(String codeShareCodeId){
        try {

            List<Code_File__c> codeFileList = new List<Code_File__c>();
            codeFileList = [SELECT Id, File_Name__c, Name, Code_Share__c, File_type__c FROM Code_File__c WHERE Code_Share__c = : codeShareCodeId];

            List<Id> codeFileId = new List<Id>();
            for (Code_File__c cf : codeFileList) {
                codeFileId.add(cf.Id);
            }

            System.debug('codeFileId---->'+codeFileId);

            List<ContentVersion> files = new List<contentVersion>();
            files = [SELECT  Title,FirstPublishLocationId,FileExtension, PathOnClient, FileType, VersionData FROM ContentVersion WHERE FirstPublishLocationId IN : codeFileId];

            Integer i = 0;
            List<CodeFileWrapper> cfData = new List<CodeFileWrapper>();
            for (ContentVersion cv : files) {
                CodeFileWrapper cf = new CodeFileWrapper();
                cf.index = i;
                cf.fileName = cv.Title;
                cf.fileType = cv.fileType;
                cf.versionDataUrl = EncodingUtil.base64Encode(cv.VersionData);
                cf.fileExtension = cv.FileExtension;
                cfData.add(cf);
                i++;
            }

            System.debug('cfData--->'+cfData);

            return  cfData;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class CodeFileWrapper {
        @AuraEnabled
        public Integer index {get; set;}
        @AuraEnabled
        public String fileName {get; set;}
        @AuraEnabled
        public String fileType {get; set;}
        @AuraEnabled
        public String fileExtension {get; set;}
        @AuraEnabled
        public String versionDataUrl {get; set;}
    
}

}