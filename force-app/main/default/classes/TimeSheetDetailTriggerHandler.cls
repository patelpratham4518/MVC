public without sharing class TimeSheetDetailTriggerHandler {
    List<Timesheet_Detail__c> recordNewList = new List<Timesheet_Detail__c>();
    List<Timesheet_Detail__c> recordOldList = new List<Timesheet_Detail__c>();
    Map<Id, Timesheet_Detail__c> recordNewMap = new Map<Id, Timesheet_Detail__c>();
    Map<Id, Timesheet_Detail__c> recordOldMap = new Map<Id, Timesheet_Detail__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = true;
    public static boolean flag = true;
    
    public TimeSheetDetailTriggerHandler(List<Timesheet_Detail__c> newList, List<Timesheet_Detail__c> oldList, Map<Id, Timesheet_Detail__c> newMap, Map<Id, Timesheet_Detail__c> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
        this.recordNewList = newList;
        this.recordOldList = oldList;
        this.recordNewMap = newMap;
        this.recordOldMap = oldMap;
        this.isInsert = isInsert;
        this.isUpdate = isUpdate;
        this.isDelete = isDelete;
        this.isUndelete = isUndelete;
    }
    
    public void BeforeInsertEvent(){}
    
    public void BeforeUpdateEvent(){         
        
    }
    
    public void BeforeDeleteEvent(){}
    
    public void AfterInsertEvent(){
        updateTimesheetHandler();
    }
    
    public void AfterUpdateEvent(){
        updateTimesheetHandler();
    }
    
    public void AfterDeleteEvent(){}
    
    public void AfterUndeleteEvent(){}
    
    public void updateTimesheetHandler(){
        
        Set<Id> parentIds = new Set<Id>();
        for(Timesheet_Detail__c t: this.recordNewList) parentIds.add(t.Timesheet__c);
        
        List<Timesheet_Detail__c> allrecords = [SELECT Id,Name,Timesheet__c,Status__c FROM Timesheet_Detail__c WHERE Timesheet__c =: parentIds AND Timesheet__r.isSubmitted__c = true];
        
        Map<id,refWrap> handlerMap = new Map<Id,refWrap>();
        for(Timesheet_Detail__c t: allrecords){
            System.debug('t Status->'+t.Status__c);
            if(!handlerMap.containsKey(t.Timesheet__c)){
                refWrap r = new refWrap();
                if(t.Status__c != 'Pending For Approval' && t.Status__c != null) r.approvedOrNot = t.Status__c == 'Approved' ? true : false;
                r.allUpdated = t.Status__c == 'Pending For Approval' || t.Status__c == null ? false : true;
                handlerMap.put(t.Timesheet__c,r);
            }else{
                refWrap r = handlerMap.get(t.Timesheet__c);
                if(t.Status__c != 'Pending For Approval' && t.Status__c != null && (r.approvedOrNot == true)) r.approvedOrNot = t.Status__c == 'Approved' ? true : false;
                r.allUpdated = (t.Status__c != 'Pending For Approval' && t.Status__c != null) && r.allUpdated ? true : false;
                handlerMap.put(t.Timesheet__c,r);
            }
            System.debug('-->'+handlerMap.get(t.Timesheet__c).allUpdated+'---'+handlerMap.get(t.Timesheet__c).approvedOrNot);
        }
        
        System.debug(handlerMap);
        
		List<Timesheet__c> parentList = [SELECT Id, Name, Status__c,Contact__r.Name,Team__r.Lead_Email__c,Contact__r.MobilePhone,Contact__r.Email, Contact__r.Slack_Id__c,Team__r.Lead_Name__c,Date__c FROM Timesheet__c WHERE Id=: handlerMap.keyset() ];
        for(Integer i =0;i<parentList.size();i++){
            if(handlerMap.get(parentList[i].Id).allUpdated){
                if(handlerMap.get(parentList[i].Id).approvedOrNot != null) parentList[i].Status__c = handlerMap.get(parentList[i].Id).approvedOrNot ? 'Approved' : 'Rejected'; 
                
                Date dt = parentList[0].Date__c;
                String message = 'Hi ' + parentList[0].Contact__r.Name + ', \n\n';
                message += 'Greetings for the day! \n';
                message += 'Your TimeSheet has been'+' *'+parentList[0].Status__c+'*'+' for *'+dt.day()+'/'+dt.month()+'/'+dt.year()+'*.';

                // WhatsappIntegration.sendMessage(parentList[0].Contact__r.MobilePhone, parentList[0].Contact__r.Name, message);
                if (String.isNotBlank(parentList[0].Contact__r.Slack_Id__c)) {
                    SlackIntegration.sendSlackMessage(message, parentList[0].Contact__r.Slack_Id__c);
                }

            }else{
                parentList[i].Status__c = '';
            }
        }

        System.debug('parentList>>>'+parentList);
        update parentList;
       
    }
    
    // @future (callout=true) 
    // public static void sendGmail(String subjectMail,String bodyGmail,String sendTo){ 
    //     String errorMessage =''; 
    //     string before = 'From: avc <abc@abc.com>\n'+ 
    //     'To: '+sendTo+'\n'+ 
    //     'Reply To: mihir.r@mvclouds.com\n'+
    //     'Subject: '+subjectMail+'\n' + 
        
    //     'Content-Type: text/html \n\n'+bodyGmail; 
        
    //     System.debug(before); 
    //     Blob beforeblob = Blob.valueOf(before); 
        
    //     string paramvalue = EncodingUtil.base64Encode(beforeblob); 
    //     paramvalue = paramvalue.replace('+', '-'); 
    //     paramvalue = paramvalue.replace('/', '_'); 
    //     System.debug(paramvalue); 
        
    //     Http httpMail = new Http(); 
    //     HttpRequest httpReqMail = new HttpRequest(); 
    //     HttpResponse httpResMail = new HttpResponse(); 
    //     httpReqMail.setEndpoint('callout:Gmail/gmail/v1/users/me/messages/send');

    //     httpReqMail.setMethod('POST'); 
    //     httpReqMail.setHeader('Content-Type', 'application/json'); 
    //     httpReqMail.setHeader('Content-Length', '-1'); 
    //     String refreshToknBody = '{"userId":"me","raw":"'+paramvalue+'"}'; 
    //     system.debug(refreshToknBody); 
    //     httpReqMail.setBody(refreshToknBody); 
    //     try{ 
    //         httpResMail = httpMail.send(httpReqMail); 
    //         if(httpResMail.getStatusCode() == 200){ 
    //             System.debug(httpResMail.getBody()); 
    //         }else{ 
    //             String errorMessageMail = 'Unexpected Error while communicating with Google Calendar API. ' +'Status '+httpResMail.getBody()+' and Status Code '+httpResMail.getStatuscode(); 
    //             System.debug('Error ' + errorMessageMail); 
    //             System.debug(httpResMail); 
    //         } 
    //     }catch(System.Exception e){ 
    //         System.debug('#### Exception Executed '+e.getStackTraceString() + ' '+e.getMessage()); 
    //     } 
    // } 

    public class refWrap{
        public Boolean allUpdated {get;set;}
        public Boolean approvedOrNot {get;set;}
    }
}