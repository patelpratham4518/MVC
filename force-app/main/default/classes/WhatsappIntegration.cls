public class WhatsappIntegration {

    @future (callout=true) 
    public static void sendMessage(String mobilenumber,String UserName, String message){
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://graph.facebook.com/v15.0/101752309531369/messages');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            //request.setHeader('Authorization', 'Bearer EABfIW7O6jtgBAI8ZCJYyiJu0gcNLAJAP3oAqyDsjbCZB2PyouA7DKyE7cyoc3D041XnxJyzpVrCzpCKwkT4ih0ioEV0XoAP44EafVva8hjhhZA0SRnXd0ljJe8LiMAOP2uQ9JBT7r9IrzZCaZCwrbhJpMePaMMiZCSSMIKucusTiP9ION4ra3gZCk2Q53vI3PKbI2NwM6b4RQZDZD');
			request.setHeader('Authorization', 'Bearer EABfIW7O6jtgBAI8ZCJYyiJu0gcNLAJAP3oAqyDsjbCZB2PyouA7DKyE7cyoc3D041XnxJyzpVrCzpCKwkT4ih0ioEV0XoAP44EafVva8hjhhZA0SRnXd0ljJe8LiMAOP2uQ9JBT7r9IrzZCaZCwrbhJpMePaMMiZCSSMIKucusTiP9ION4ra3gZCk2Q53vI3PKbI2NwM6b4RQZDZD');
            //String mobilenumber = '917227889609';
            String sendbody = '';
            
            // First Time for Authorization
            // sendbody = '{ "messaging_product": "whatsapp", "to": '+mobilenumber+', "type": "template", "template": { "name": "welcome_message", "language": { "code": "en_us" } } }';
            
            // //For Custom Message
            // sendbody = '{ "messaging_product": "whatsapp", "preview_url": false, "recipient_type" :"individual", "to": '+mobilenumber+',"type":"text", "text": {"body": \''+message+'\'}}';
                                   
            // generic custom message 
            sendbody =  '{ "messaging_product": "whatsapp","to":'+mobilenumber+',"type":"template","template":{"language":{"policy":"deterministic","code":"en_US"},"name":"timesheet_genericmessage","components":[{"type":"body","parameters":[{"type":"text","text":"'+UserName+'"},{"type":"text","text":"'+message+'"}]}]}}';
            
            request.setBody(sendbody);

            System.debug('Body sent:'+request.getBody());
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                System.debug('Success::'+response.getBody());
            } else {
                System.debug('Error::'+response.getBody());
            }   

            
        } catch(Exception e) {
            System.debug('ERROR===>'+e.getMessage());
        }
    }

    @future (callout=true) 
    public static void TimesheetSubmitReminder(String mobilenumber, String ContactName){
        try {
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint('https://graph.facebook.com/v15.0/101752309531369/messages');
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json');
                request.setHeader('Authorization', 'Bearer EABfIW7O6jtgBAI8ZCJYyiJu0gcNLAJAP3oAqyDsjbCZB2PyouA7DKyE7cyoc3D041XnxJyzpVrCzpCKwkT4ih0ioEV0XoAP44EafVva8hjhhZA0SRnXd0ljJe8LiMAOP2uQ9JBT7r9IrzZCaZCwrbhJpMePaMMiZCSSMIKucusTiP9ION4ra3gZCk2Q53vI3PKbI2NwM6b4RQZDZD');
                // String mobilenumber = NoList;
                String sendbody = '';
                String message = 'Hi, '+'*'+ContactName+'*'+'  We hope you are doing well...!!   This message is just to remind you to Submit your Timesheet for today as soon as you can.  -MV Clouds Portal!';
                
                //First Time for Authorization
                //sendbody = '{ "messaging_product": "whatsapp", "to": '+mobilenumber+', "type": "template", "template": { "name": "hello_world", "language": { "code": "en_us" } } }';
                
                //For Custom Message
                sendbody = '{ "messaging_product": "whatsapp", "preview_url": false, "recipient_type" :"individual", "to": '+mobilenumber+',"type":"text", "text": {"body": \''+message+'\'}}';
                
                request.setBody(sendbody);
    
                System.debug('Body sent:'+request.getBody());
                HttpResponse response = http.send(request);
                if (response.getStatusCode() == 200) {
                    System.debug('Success::'+response.getBody());
                } else {
                    System.debug('Error::'+response.getBody());
                }   
            
        } catch(Exception e) {
            System.debug('ERROR===>'+e.getMessage());
        }
    } 
}