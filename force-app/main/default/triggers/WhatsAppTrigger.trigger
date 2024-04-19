trigger WhatsAppTrigger on Whatsapp_Message__c (after insert) {

    Map<String, Whatsapp_Message__c> WhatsAppMap = new Map<String, Whatsapp_Message__c>();
    for (Whatsapp_Message__c wpm : Trigger.new) {        
        try{
            String[] wpmsg = wpm.Message__c.split(' ');
            String status = wpmsg[0];
            String wpname = wpmsg[2] +' '+ wpmsg[3];
            
            if(wpm.Contact_Phone__c == '919662324880'){
                //9662324880
                Leave__c lvlst = [SELECT Id, Name, Status__c, Contact_Trainee__c, Contact_Trainee__r.Name FROM Leave__c WHERE Contact_Trainee__r.Name =: wpname AND Status__c = 'Pending for Approval' ORDER By LastmodifiedDate DESC LIMIT 1];
                if(status == 'Approve') {
                    lvlst.Status__c = 'Approved';
                } else if (status == 'Reject') {
                    lvlst.Status__c = 'Rejected';
                }
                update lvlst;
            }
        } catch(Exception e) {
            System.debug('e--->'+e.getMessage());
        }
    }   
}