public class PdfTransferTriggerhandler {
	List<Contact> recordNewList = new List<Contact>();
    List<Contact> recordOldList = new List<Contact>();
    Map<Id, Contact> recordNewMap = new Map<Id, Contact>();
    Map<Id, Contact> recordOldMap = new Map<Id, Contact>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = false;
    
    public PdfTransferTriggerhandler(List<Contact> newList, List<Contact> oldList, Map<Id, Contact> newMap, Map<Id, Contact> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
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
    
    public void BeforeUpdateEvent(){}
    
    public void BeforeDeleteEvent(){}
    
    public void AfterInsertEvent(){
        
        for(Contact con: recordNewList){
            Attachment attach = [SELECT Id,ParentId FROM Attachment WHERE ParentId = '0036F00003cGNC6QAO' ORDER BY CreatedDate DESC LIMIT 1];
            attach.ParentId = con.Id;
            update attach;
        }
        
    }
    
    public void AfterUpdateEvent(){
    }
    
    public void AfterDeleteEvent(){}
    
    public void AfterUndeleteEvent(){}
    
}