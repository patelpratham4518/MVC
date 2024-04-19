public Without sharing class AutoLead {
    @AuraEnabled
    public static string creatLeadRecord(string mMail, Lead leadObj, String recordId){
        try{       
            List<Lead> ls = new List<Lead>();   
            ls= [Select Id From Lead where Email =: leadObj.Email LIMIT 1];
            system.debug(ls);
            if(ls.size() > 0){
                system.debug('size of the list'+ls.size());
                return 'Error';
            }
            else{
                upsert leadObj;
                //    system.debug('count'+count);
                System.debug('recordId'+recordId);
                System.debug('leadObj.Id'+leadObj.Id);
                
                webinarAttendee__c	 wa = new webinarAttendee__c ();
                wa.webinarlLead__c = leadObj.Id;
                wa.webinar__c	  = recordId ;
                insert wa;
                // sendMailMethod('Mail');
                
               List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();    
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                List<String> sendTo = new List<String>();
                sendTo.add(mMail);
                mail.setToAddresses(sendTo);
                
                mail.setReplyTo('noreply@gmail.com'); 
                mail.setSenderDisplayName('salesforce User'); 
                string Htmlbody =+ '<br><br><a href="https://dharmikmvclouds-developer-edition.ap4.force.com/WebinarThankYou?id='+wa.Id+'">Click Here for confirmation.</a>';
                system.debug(Htmlbody);
                mail.setSubject('Salesforce Webinar');
                mail.setHtmlBody(Htmlbody);
                mails.add(mail);
                Messaging.sendEmail(mails); 
                return 'Success';     
                
            }
            // return leadObj.id;
            
        }
        catch(Exception e){
            throw new AuraHandledException('Error Exception happend'+e.getMessage());           
        }       
    }
}