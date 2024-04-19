public class whapinController {

    public List<Whatsapp_Message__c> messagesList{get;set;}  
    public List<Contact> contactList{get;set;}
    public String RecordId{get;set;}
    
    public whapinController(ApexPages.StandardController controller){
        messagesList = new List<Whatsapp_Message__c>();
        RecordId = controller.getId();
        System.debug('Record Id '+RecordId);
        doGetAllMessages();
        dogetContacts();
    }
    
    public void doGetAllMessages(){
        messagesList = [Select Name, CreatedDate from Whatsapp_Message__c Where Contact__c =:RecordId];
        System.debug('messages == >> '+messagesList);
    }
    
    public void dogetContacts(){
        contactList = [Select Id,Name,phone,Email,Account.Name from Contact Where phone != null AND Id !=: RecordId order by CreatedDate DESC];
        System.debug('Contacts List' +contactList);
    }
   
}