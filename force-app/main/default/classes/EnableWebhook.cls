@RestResource(urlMapping='/whatsappwebhook')
global class EnableWebhook {
    @HttpGet
    global static Integer doGet() {
        RestRequest request =  RestContext.request;
        RestResponse response = RestContext.response;
		
        if(request.params.get('hub.veridy_token') == 'EABfIW7O6jtgBAI8ZCJYyiJu0gcNLAJAP3oAqyDsjbCZB2PyouA7DKyE7cyoc3D041XnxJyzpVrCzpCKwkT4ih0ioEV0XoAP44EafVva8hjhhZA0SRnXd0ljJe8LiMAOP2uQ9JBT7r9IrzZCaZCwrbhJpMePaMMiZCSSMIKucusTiP9ION4ra3gZCk2Q53vI3PKbI2NwM6b4RQZDZD'){
            response.responseBody = Blob.valueOf(request.params.get('hub.challenge'));
        }
		String sr = request.params.get('hub.challenge');
        System.debug('s-rr-->'+sr);
        return 0;
    }

    @HttpPost
    global static void doPost() {
        try {
            
            String resbody = RestContext.request.requestBody.toString();
            
            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(resbody);
            
            List<Object> entryList = (List<Object>)jsonMap.get('entry');
            Map<String, Object> entryMap = (Map<String, Object>)entryList[0];
            List<Object> changesList = (List<Object>)entryMap.get('changes');
            Map<String, Object> changesMap = (Map<String, Object>)changesList[0];
            Map<String, Object> valueMap = (Map<String, Object>)changesMap.get('value');

            // To get Value of Sender Number
            List<Object> contactsList = (List<Object>)valueMap.get('contacts');
            Map<String, Object> contactMap = (Map<String, Object>)contactsList[0];
            String senderWpNumer = (String)contactMap.get('wa_id');
            
            // To get Value of Sender Name
            Map<String, Object> profileMap = (Map<String, Object>)contactMap.get('profile');
            String senderName = (String)profileMap.get('name');

            
            // To get Value of Message
            List<Object> messagesList = (List<Object>)valueMap.get('messages');
            Map<String, Object> messageMap = (Map<String, Object>)messagesList[0];
            Map<String, Object> textMap = (Map<String, Object>)messageMap.get('text');
            String msgbody = (String)textMap.get('body');


            System.debug('senderName-->'+senderName);
            System.debug('senderWpNumer-->'+senderWpNumer);
            System.debug('msgbody-->'+msgbody);
            
            Whatsapp_Message__c wpm = new Whatsapp_Message__c();
            wpm.Name = senderName;
            wpm.Contact_Phone__c = senderWpNumer;
            wpm.Message__c = msgbody;
			insert wpm;
            
            
        } catch (Exception e) {
            System.debug('ERROR-->'+e.getMessage());
        }
    }   

}