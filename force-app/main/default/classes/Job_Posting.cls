public class Job_Posting {
    public List<Job_Posting__c> JpList {get;set;}
    public Map<set<Id>,Job_Posting__c> JpMap {get;set;}
    public Set<id>  attIds {get;set;}
    public Map<Id, String> jpAttachMap {get;set;}
    public String get_url {get;set;}

    public Job_Posting(){
        get_url = URL.getSalesforceBaseUrl().toExternalForm();
        System.debug('url :::'+get_url);
        System.debug('Jp List :::'+JpList);
        JpList = [SELECT Id, Job_Name__c, short_description__c FROM Job_Posting__c WHERE On_Off__c  = true ORDER BY CreatedDate ASC]; //* Job_Description must be change to new field whenever goes for deployment
        System.debug('Jp List :::'+JpList);
        List<Id> jpIds = new List<Id>();
        for(Job_Posting__c jp : JpList){
            jpIds.add(jp.Id);
        }
        
        jpAttachMap =  new Map<Id,String>();
        for(Attachment attach : [SELECT Id , parentid,Body,ContentType FROM Attachment WHERE ParentId IN:jpIds]){


            String blobURL = 'data:'+attach.ContentType+';base64,'+EncodingUtil.base64Encode(attach.body);

            // System.debug('fsdfsfadsfadsfd'+attach.parentid);
                // jpAttachMap.put(attach.ParentId, attach.Id);
                System.debug('blobURL-->'+blobURL);
                jpAttachMap.put(attach.ParentId, blobURL);
        }
        System.debug('jpAttachMap ::: '+jpAttachMap);
    }   
    
}