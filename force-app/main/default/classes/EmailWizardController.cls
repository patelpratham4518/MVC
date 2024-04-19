public class EmailWizardController {

    public static Map<String, String> blobMapOfRichTextImg = new Map<String, String>();
    
    @AuraEnabled 
    public static List<LeadListWrapper> fetchAccountWrapper(String objname){     
        List<LeadListWrapper> lstLeadListWrapper = new List<LeadListWrapper>();
        String query;
        if (objname == 'Lead') {
            query = 'SELECT Id, Name, Phone, Email, LeadSource FROM ' +objname+ ' ORDER BY CreatedDate Desc';
        } else {
            query = 'SELECT Id, Name, Phone, Email FROM ' +objname+ ' ORDER BY CreatedDate Desc';
        }
        
        for (SObject sobj : Database.query(query)) {
            lstLeadListWrapper.add(new LeadListWrapper(false,sobj));
        }

        System.debug('lstLeadListWrapper==>'+lstLeadListWrapper);
        return lstLeadListWrapper; 
    }
    
    /* wrapper class */  
    public class LeadListWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public SObject objAccount{get;set;}
        public LeadListWrapper(boolean isChecked, SObject objAccount){
            this.isChecked = isChecked;
            this.objAccount = objAccount;
        }
    }

    // get Search Record
    @AuraEnabled
    public static List<LeadListWrapper> getSearchValue(String objname, String searchname , String leadSource){
        List<LeadListWrapper> lstLeadListWrapper = new List<LeadListWrapper>();
        String query;

        if (objname == 'Lead') {
            if(leadSource == '--None--' && (searchname == null || searchname == '' || searchname == ' ')){
                query = 'SELECT Id, Name, Phone, Email, LeadSource FROM ' +objname+ ' ORDER BY CreatedDate Desc';
            }
            else if (leadSource == '--None--' && (searchname != null && searchname != '' && searchname != ' ')) {
                query = 'SELECT Id, Name, Phone, Email , LeadSource FROM ' +objname+ ' WHERE Name LIKE  \''+ '%'+searchname+'%\' ORDER BY CreatedDate Desc';
            }
            else if( leadSource != '--None--' && (searchname != null && searchname != '' && searchname != ' ')) {
                query = 'SELECT Id, Name, Phone, Email , LeadSource FROM ' +objname+ ' WHERE Name LIKE  \''+ '%'+searchname+'%\' AND LeadSource = \''+leadSource+'\' ORDER BY CreatedDate Desc';
            }
            else if( leadSource != '--None--' && (searchname == null || searchname == '' || searchname == ' ')) {
                query = 'SELECT Id, Name, Phone, Email , LeadSource FROM ' +objname+ ' WHERE LeadSource = \''+leadSource+'\' ORDER BY CreatedDate Desc';
            }
        }
        else{
            if (searchname != null && searchname != '' && searchname != ' ') {
                query = 'SELECT Id, Name, Phone, Email FROM ' +objname+ ' WHERE Name LIKE  \''+ '%'+searchname+'%\' ORDER BY CreatedDate Desc';
            }
            else {
                query = 'SELECT Id, Name, Phone, Email FROM ' +objname+ ' ORDER BY CreatedDate Desc';
            }
        }

        System.debug('query-->'+query);
        
        for (SObject sobj : Database.query(query)) {
            lstLeadListWrapper.add(new LeadListWrapper(false,sobj));
        }

        System.debug('lstLeadListWrapper==>'+lstLeadListWrapper);
        return lstLeadListWrapper; 
    }
    // get all Object
    @AuraEnabled
    public static List<String> getObjectName(){
        List<String> objects=new List<String>();
        List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();  
        for(SObjectType sot:gd){
            objects.add(sot.getDescribe().getName());
            objects.sort();  
        }
        return objects;
    }

    @AuraEnabled
    public static List<emailTemplates> getEmailTemaltes(){
        List<emailTemplates> TemplateList = new List<emailTemplates>();
        for(sobject emailtemp : [ SELECT Id, FolderId, HtmlValue, FolderName, isActive, body,Name,subject FROM EmailTemplate where isActive= true]){        
            EmailTemplates template = new EmailTemplates();
            template.emailTemplateId = String.valueOf(emailtemp.get('Id'));
            template.emailTemplatename = String.valueOf(emailtemp.get('Name'));
            template.emailbody = (emailtemp.get('HtmlValue') != null ? String.valueOf(emailtemp.get('HtmlValue')) : '' );
            template.emailSubject = String.valueOf(emailtemp.get('subject'));
            TemplateList.add(template);
        }
        return TemplateList;
    }

    public class emailTemplates{
        
        @AuraEnabled 
        public String emailTemplateId{get;set;}
        
        @AuraEnabled 
        public String emailbody{get;set;}
        
        @AuraEnabled
        public String emailSubject {get;set;}
        
        @AuraEnabled 
        public String emailTemplatename{get;set;}
    } 
    @AuraEnabled
    public static List<String> getAllFields(String objname){
        System.debug('objname-->'+objname);
        List<String> fieldList = new List<String>();
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        // Schema.SObjectType sobjType = gd.get('Lead'); 
        Schema.SObjectType sobjType = gd.get(objname); 
        Schema.DescribeSObjectResult describeResult = sobjType.getDescribe(); 
        Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap(); 
        
        for(string str: fieldsMap.keySet()){
            String refVar = fieldsMap.get(str).getDescribe().getLabel() + ':::' + fieldsMap.get(str).getDescribe().getName();
            fieldList.add(refVar);
        }

        return fieldList;      
    }

    @AuraEnabled
    public static String SendMailsMethod(List<Id> IdList , String Subject, String MailBody,String FileName,String FileType,Blob FileBlob,String objname){
        try {

            String FileBlobStr = EncodingUtil.base64Encode(FileBlob);

            Map<Id,String> LeadMailMap = new Map<Id,String>();
            LeadMailMap = changeLead(MailBody,IdList,objname);
            
            EmailWizardBatch emailbatch = new EmailWizardBatch(JSON.serialize(IdList), JSON.serialize(LeadMailMap) ,objname, Subject, FileBlob, FileName, FileType, blobMapOfRichTextImg);
            Database.executeBatch(emailbatch, 80);

            return 'Emails Sent Successfully!!';
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static string getPreview(Id recordId,String MailBody,String objname){
        try {
            List<sObject> SObjectlist = Database.query(Util.queryData(objname,'',' WHERE Id =: recordId LIMIT 1'));
            System.debug('SObjectlist==>'+SObjectlist);
            List<Id> LeadIdList = new List<Id>();
            // for(Lead c: LeadList){
            //     LeadIdList.add(c.Id);
            // }
            for (SObject sobj : SObjectlist) {
                LeadIdList.add(sobj.Id);
            }
            System.debug('LeadIdList==>'+LeadIdList);
            Map<Id,String> LeadMailMap  = new Map<Id,String>();
            LeadMailMap = changeLead(MailBody,LeadIdList,objname);
            // String updatedMailBody = changeLead(MailBody,LeadIdList);
            String updatedMailBody = LeadMailMap.get(SObjectlist[0].Id);
            System.debug('updatedMailBody==>'+updatedMailBody);
            return updatedMailBody;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static Map<Id,String> changeLead(String MailBody,List<Id> recordId,String objname){        
        List<sObject> sObjectlst = Database.query(Util.queryData(objname,'',' WHERE Id =: recordId'));
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(objname).getDescribe().fields.getMap();
        List<String> ListFields = new List<String>();
        for(Schema.SObjectField sfield : fieldMap.Values()){
            ListFields.add(sfield.getDescribe().getname());
        }

        Map<Id,String> LeadMailMap = new Map<Id,String>();

        for(sObject c: sObjectlst){
            String refMail = MailBody;
            for(String s: ListFields){                
                String x = '{!'+objname+'.'+s+'}';
                if(refMail.contains(x)){
                    String strval = String.valueOf(c.get(s));
                    if(strval != null){
                        refMail = refMail.replace(x,String.valueOf(c.get(s)));
                    }else {
                        refMail = refMail.replace(x, '');
                    }
                }
            }
            LeadMailMap.put(c.Id,refMail);
        }

        return LeadMailMap;
    }

    // For Getting Lead Filter value
    @AuraEnabled 
    public static Map<String, String> getLeadSourceFieldValue(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Lead.LeadSource.getDescribe();
        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }

}