public without sharing class MasterPageController {

    @AuraEnabled
 public static List < contact > fetchContact(String searchKeyWord) {
  String searchKey = '%' + searchKeyWord + '%';
  List < Contact > returnList = new List < Contact > ();
  List<Contact> lstOfContact = new List < Contact > ();
  
  System.debug(searchKeyWord);
  System.debug(searchKey);

  
  
  if(searchKey == null || searchKey == ''){
    return null;
  }
  if(searchKey != null || searchKey != ''){
    lstOfContact = [SELECT Id, Name FROM Contact WHERE Name LIKE: searchKey ];
  }
  
 
  for (Contact con: lstOfContact) {
   returnList.add(con);
  }
  return returnList;
 }
    @AuraEnabled
    public static boolean iptest(){
        String ipval = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        String myip = '110.227.237.81';
        System.debug(ipval);
        if(ipval == myip){
            return true;
        }else{
            return false;
        }
    }

    // TO PREVIEW PDF
    @AuraEnabled
    public static string pdfview(string reid){
        Attachment attach = new Attachment();
        string pdfvalue;
        
        System.debug(reid);
        // Job_Application__c job = new Job_Application__c();
        // job =[SELECT Id,Contact__r.Id FROM Job_Application__c WHERE Id =: reid];
        // String conid = job.Contact__r.Id;
        attach = [SELECT Id,Name,Body,ContentType FROM Attachment WHERE ParentId =: reid LIMIT 1];
        String contype = attach.ContentType;
        Blob attachbody = attach.Body;
        pdfvalue= '';
        pdfvalue= EncodingUtil.base64Encode(attachbody);

        return contype+','+pdfvalue;
        
    }

    @AuraEnabled
    public static string scheduleShow(String conid){

      Job_Application__c Job = [SELECT Status__c, Contact__c FROM Job_Application__c WHERE Contact__c =:conid ];
      

      return Job.Status__c;
    }

    @AuraEnabled
    public static string getInterviewId(String conid,String RoundName){
      Interview__c Inter = new Interview__c();
      if(RoundName == '1st'){
      Inter = [SELECT Id,RecordType.Name FROM Interview__c WHERE Job_Application__r.Contact__c =: conid AND RecordType.Name = 'First Round'];
      return Inter.Id;
      }

      if(RoundName == '2nd'){
      Inter = [SELECT Id,RecordType.Name FROM Interview__c WHERE Job_Application__r.Contact__c =: conid AND RecordType.Name = 'Second Round'];
      return Inter.Id;
      }
      return null;
    }
}