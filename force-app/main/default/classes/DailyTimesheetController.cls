public class DailyTimesheetController {

    @InvocableMethod(label='Daily Timesheet' description='Method description')
    public static void getTimesheetRecord(List<Id> tsIds) {

        List<Timesheet__c> timesheet = [SELECT Id,Name,Date__c,Team__c,Team__r.Lead_Email__c,Team__r.Lead_Name__c,Contact__r.Name FROM Timesheet__c where Date__c =: Date.today().addDays(-1)];
        System.debug('timesheet>>>'+timesheet);
        System.debug('timesheet size>>>'+timesheet.size());
        
        Set<Id> tIds = new Set<Id>();
        Map<Id,List<Timesheet__c>> tmMap = new Map<Id,List<Timesheet__c>>();

        for(Timesheet__c t : timesheet){            
            // if(!tmMap.containsKey(t.Team__c)){
            //     tmMap.put(t.Team__c,new List<Timesheet__c>());
            // }
            // tmMap.get(t.Team__c).add(t);
            String bodygmail = 'Hi '+t.Team__r.Lead_Name__c+', <br/> <br/>';
            bodygmail += +t.Contact__r.Name+ ' has updated the timesheet <b>';
            bodygmail += '<br/> <br/> <a href=\"https://mvclouds5-dev-ed.my.salesforce.com/'+t.id+'" target="_blank"> Click here </a> for approve or reject Timesheet.';
            bodygmail += '<br/> <br/> Thanks,';
            bodygmail += '<br/>Mv Team';
            sendGmail('Timesheet Update',bodyGmail,t.Team__r.Lead_Email__c); 
        }
    }
        

    @future (callout=true) 
    public static void sendGmail(String subjectMail,String bodyGmail,String sendTo){ 
        String errorMessage =''; 
        string before = 'From: avc <abc@abc.com>\n'+ 
        'To: '+sendTo+'\n'+ 
        'Subject: '+subjectMail+'\n' + 
        'Content-Type: text/html \n\n'+bodyGmail; 
        
        System.debug(before); 
        Blob beforeblob = Blob.valueOf(before); 
        
        string paramvalue = EncodingUtil.base64Encode(beforeblob); 
        paramvalue = paramvalue.replace('+', '-'); 
        paramvalue = paramvalue.replace('/', '_'); 
        System.debug(paramvalue); 
        
        Http httpMail = new Http(); 
        HttpRequest httpReqMail = new HttpRequest(); 
        HttpResponse httpResMail = new HttpResponse(); 
        httpReqMail.setEndpoint('callout:Gmail/gmail/v1/users/me/messages/send');

        httpReqMail.setMethod('POST'); 
        httpReqMail.setHeader('Content-Type', 'application/json'); 
        httpReqMail.setHeader('Content-Length', '-1'); 
        String refreshToknBody = '{"userId":"me","raw":"'+paramvalue+'"}'; 
        system.debug(refreshToknBody); 
        httpReqMail.setBody(refreshToknBody); 
        try{ 
            httpResMail = httpMail.send(httpReqMail); 
            if(httpResMail.getStatusCode() == 200){ 
                System.debug(httpResMail.getBody()); 
            }else{ 
                String errorMessageMail = 'Unexpected Error while communicating with Google Calendar API. ' +'Status '+httpResMail.getBody()+' and Status Code '+httpResMail.getStatuscode(); 
                System.debug('Error ' + errorMessageMail); 
                System.debug(httpResMail); 
            } 
        }catch(System.Exception e){ 
            System.debug('#### Exception Executed '+e.getStackTraceString() + ' '+e.getMessage()); 
        } 
    }    
}