public class WhatsAppController{

    public String message{get;set;}
    public String Phone{get;set;}
    public Contact thisContact{get;set;}
    public Boolean showStatus{get;set;}
    public String statusMessage{get;set;}
    public static String Contact_To_Search{get;set;}
	
    List<Whatsapp_Message__c> whatsappMessages{get;set;}
    
    public WhatsAppController(ApexPages.StandardController controller){
        whatsappMessages = new List<Whatsapp_Message__c>();
        controller.addFields(new List<String>{'Phone'});
        this.thisContact = (Contact)controller.getRecord();
        showStatus = false;
        //message='Hello '+thisContact.Name +',\n';
        Phone=thisContact.Phone;
        Contact_To_Search='';
    }

    public void sendMessage(){
        if(message == null || message == ''){
            statusMessage ='Please enter some message';
            showStatus = true;
        }
        else{
            Http http = new Http();
            System.debug('message::'+message);
            System.debug('Phone::'+Phone);
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://eu12.chat-api.com/instance9887/message?token=ay49ffdwr36lmfl9'); //https://eu12.chat-api.com/instance9887/ and token ay49ffdwr36lmfl9
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            //system.debug(EncodingUtil.urlEncode(message, 'UTF-8'));
            message = message.replace('\r\n', ' ');
            message = message.replace('\n', ' ');
            message = message.replace('\r', ' ');
            System.debug('message after split::'+message);
            request.setBody('{"phone": "'+phone+'","body": "'+message+'"}');
            System.debug('Body sent:'+request.getBody());
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                System.debug('Success::'+response.getBody());
                Contact conDetail = [Select id,Name from Contact Where Phone =: Phone];
                Whatsapp_Message__c whapinSendMessage = new Whatsapp_Message__c();
                whapinSendMessage.Contact__c = conDetail.id;
                whapinSendMessage.Message_Id__c = message;
                whapinSendMessage.Contact_Phone__c = Phone;
                
                whatsappMessages.add(whapinSendMessage);
                if(whatsappMessages.size()>0){
                    insert whatsappMessages;
                }
                
            } else {
                System.debug('Error::'+response.getBody());
            }
            message ='';
            statusMessage = 'Message Sent';
            showStatus = true; 
        }
    }
    @future(callout=true)
    public static void doget() {
        List<String> Contact_To_Search_List = new List<String>();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://eu12.chat-api.com/instance9887/messages?last&token=ay49ffdwr36lmfl9'); //https://eu12.chat-api.com/instance9887/ and token ay49ffdwr36lmfl9
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        System.debug('body::'+response.getBody());
        if (response.getStatusCode() == 200) {
            List<Whatsapp_Message__c> allMesg_Media = new List<Whatsapp_Message__c>();
            List<Whatsapp_Message__c> allMesg_NonMedia = new List<Whatsapp_Message__c>();
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Integer lastMessageNumber = Integer.valueof(results.get('lastMessageNumber'));
            List<Object> ReturnedMsg = (List<Object>) results.get('messages');
            System.debug('Received the following messages:'+ReturnedMsg);
            //Whatsapp_Message__c WH_msg = new Whatsapp_Message__c();
            Set<String> ContactsSet = new Set<String>();
            for(Object objj: returnedMsg){
                Map<String, Object> ii = (Map<String, Object>)objj;
                String Contact_To_Search_for_set = '';
                if(ii.get('fromMe')==false){
                   Contact_To_Search_for_set=String.valueOf(ii.get('chatId'));
                   Contact_To_Search_for_set=Contact_To_Search_for_set.left(Contact_To_Search_for_set.length()-5);
                   ContactsSet.add(Contact_To_Search_for_set);
                }
            }
            Map<String,String> mapContactPhone = new Map<String,String>();
            for(Contact objContact : [SELECT Id, phone FROM Contact WHERE phone IN: ContactsSet]){
                mapContactPhone.put(String.valueOf(objContact.phone),objContact.Id);
            }
            for (Object obj: ReturnedMsg) {
                Whatsapp_Message__c WH_msg = new Whatsapp_Message__c();
                Map<String, Object> i = (Map<String, Object>)obj;
                if(i.get('fromMe')==false){
                   if(String.valueOf(i.get('body')).startsWithIgnoreCase('https')){
                      WH_msg.Name='Media File'+'-'+System.now();
                      WH_msg.Message_Id__c=String.valueOf(i.get('id'));
                      WH_msg.Audio_URL__c=String.valueOf(i.get('body'));
                      Contact_To_Search=String.valueOf(i.get('chatId'));
                      Contact_To_Search=Contact_To_Search.left(Contact_To_Search.length()-5);
                      if(mapCOntactPhone.containsKey(Contact_To_Search)){
                           WH_msg.Contact_Phone__c = Contact_To_Search;
                           WH_msg.Contact__c = mapContactPhone.get(Contact_To_Search);
                      }
                      if(String.isNotBlank(WH_msg.Name)){
                         allMesg_Media.add(WH_msg);
                      }
                   }else{
                      WH_msg.Name=String.valueOf(i.get('body'));
                      WH_msg.Message_Id__c=String.valueOf(i.get('id'));
                      Contact_To_Search=String.valueOf(i.get('chatId'));
                      Contact_To_Search=Contact_To_Search.left(Contact_To_Search.length()-5);
                      if(mapCOntactPhone.containsKey(Contact_To_Search)){
                           WH_msg.Contact_Phone__c = Contact_To_Search;
                           WH_msg.Contact__c = mapContactPhone.get(Contact_To_Search);
                      }
                      if(String.isNotBlank(WH_msg.Name)){
                         allMesg_NonMedia.add(WH_msg);
                      }
                   }
                }
            }
            System.debug('allMesg_NonMedia::'+allMesg_NonMedia);
            System.debug('allMesg_Media::'+allMesg_Media);
            if(allMesg_Media.size()>0){
               try{
                    Database.SaveResult [] ds = Database.insert(allMesg_Media,false);
                    System.debug('inserted successfully allMesg_Media');
               }catch(Exception e){
                    System.debug('inside catch block');
               }
            }
            if(allMesg_NonMedia.size()>0){
               try{
                    Database.SaveResult [] ds = Database.insert(allMesg_NonMedia,false);
                    System.debug('inserted successfully allMesg_NonMedia');
               }catch(Exception e){
                    System.debug('inside catch block NonMedia');
               }
            }
        }
        //return response;
    }
}