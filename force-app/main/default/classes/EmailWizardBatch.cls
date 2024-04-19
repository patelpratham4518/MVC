global class EmailWizardBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {


    public final List<Id> IdList;
    public final String objname;
    public final Map<Id,String> LeadMailMap;
    public final String Subject;
    public final Blob attachment;
    public final String attachmentName;
    public final String ContentType;
    public final Map<String,String> blobMapOfRichTextImg;

    global EmailWizardBatch(String IdList1, String LeadMailMap1, String objname, String Subject, Blob attachment, String attachmentName, String ContentType, Map<String,String> blobMapOfRichTextImg) {
        try {
            List<String> IdList = (List<String>) JSON.deserialize(IdList1, List<String>.class);
            this.IdList = IdList;
            Map<Id,String> LeadMailMap = (Map<Id,String>) JSON.deserialize(LeadMailMap1, Map<Id,String>.class);
            this.Subject = Subject;
            this.LeadMailMap = LeadMailMap;
            this.objname = objname;
            this.attachment = attachment;
            this.attachmentName = attachmentName;
            this.ContentType = ContentType;
            this.blobMapOfRichTextImg = blobMapOfRichTextImg;
        } catch (Exception e) {
            System.debug('ERROR MESSAGE-->'+e.getMessage());       
            System.debug('ERROR LINE-->'+e.getLineNumber());       
        }
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String sobjquery = Util.queryData(objname,'',' WHERE Id =: IdList' );
        return Database.getQueryLocator(sobjquery);
    }
    global void execute(Database.BatchableContext bc, List<SObject> records){
        sendbulkemail(records);
    }
    global void finish(Database.BatchableContext bc){

    }

    public void sendbulkemail(List<SObject> sobjlst){
        for(SObject sobj : sobjlst) {
            String Sendto = String.valueOf(sobj.get('Email'));
            sendGmailWithAttachmentBlob(Subject,LeadMailMap.get(sobj.Id),Sendto,attachment,attachmentName,ContentType, blobMapOfRichTextImg);
        }
    }
    // @future (callout=true)
    public static void sendGmailWithAttachmentBlob(String subjectMail,String bodyGmail,String sendTo, Blob attachment,String attachmentName,String ContentType, Map<String,String> blobMapOfRichTextImg){
        
        String errorMessage ='';
        
        String TestVar = EncodingUtil.base64Encode(attachment);

        String str = attachment.toString();
        // decode 
        Blob decodedBlob = EncodingUtil.base64Decode(str);
        // convert to string

        string before = '';
        string endpoint = '';
        string contentType_1 = '';
        if(!String.isEmpty(attachmentName) && !String.isEmpty(ContentType)){
            contentType_1 = 'message/rfc822';
            endpoint = 'callout:Gmail/upload/gmail/v1/users/me/messages/send?uploadType=multipart';
            before = 'From: MV Clouds <info@mvclouds.com>\n'+
            'To: '+sendTo+'\n'+
            'MIME-Version: 1.0\n'+
            'Subject: '+subjectMail+'\n' +
            'Content-Type: multipart/mixed; boundary="foo_bar_baz"\n\n'+
            
                '--foo_bar_baz\n'+
                'Content-Type: text/html; charset="UTF-8";\n'+
                '\n\n'+bodyGmail+'\n\n';
                System.debug('bodyGmail===>'+bodyGmail);
                System.debug('before-->'+before);

                if(!String.isEmpty(attachmentName) && !String.isEmpty(ContentType)){
                System.debug('not null');
                before += 
                    '--foo_bar_baz\n'+
                    'Content-Type: '+ContentType+'; \n'+
                    'Content-Transfer-Encoding: base64\n'+
                    'Content-Disposition: attachment; filename='+attachmentName+'\n\n'+
                    // EncodingUtil.base64Encode(attachment)+'\n\n--foo_bar_baz--';			
                    EncodingUtil.base64Encode(decodedBlob)+'\n\n--foo_bar_baz--';			
                    // result+'\n\n--foo_bar_baz--';
                }
        }else{
            contentType_1 = 'application/json';
            endpoint = 'callout:Gmail/upload/gmail/v1/users/me/messages/send?uploadType=multipart';
            
            // string prebefore = 'From: "MV Clouds" <info@mvclouds.com>\n'+
            string prebefore = 'From: "MV Clouds" info@mvclouds.com\n'+
                            'Reply-To: "MV Clouds" <info@mvclouds.com>\n'+
                            'To: '+sendTo+'\n'+
                            'MIME-Version: 1.0\n'+
                            'Subject: '+subjectMail+'\n' +
                            'Content-Type: multipart/mixed; boundary="foo_bar_baz"\n\n'+
                            
                            '--foo_bar_baz\n'+
                            'Content-Type: text/html; charset="UTF-8";\n'+
                            '\n\n' + bodyGmail + '\n\n';
                            System.debug('bodyGmail===>'+bodyGmail);
            for(String key : blobMapOfRichTextImg.keySet()){ 
                prebefore = prebefore + '--foo_bar_baz\n'+
                            'Content-Type: '+ 'png'+'; \n'+
                            'Content-ID: <' + key + '.png>\n'+
                            'Content-Transfer-Encoding: base64\n'+
                            'Content-Disposition: inline; filename='+ key +'\n\n'+
                            blobMapOfRichTextImg.get(key)+'\n\n';
            }
            if (blobMapOfRichTextImg.size() > 0) {
                before = prebefore + '--foo_bar_baz--';
            } else {
                before = prebefore;
            }
        }

        Http httpMail = new Http();
        HttpRequest httpReqMail = new HttpRequest();
        HttpResponse httpResMail = new HttpResponse();
        httpReqMail.setEndpoint(endpoint);
        httpReqMail.setMethod('POST');
        httpReqMail.setHeader('Content-Type', 'message/rfc822');
        httpReqMail.setHeader('Content-Length', '-1');
        System.debug('before===>>>>'+before);
        // String refreshToknBody = '{"userId":"me","raw":"'+before+'"}';
        String refreshToknBody = '{"userId":"me","raw":"'+before;
        System.debug('refreshToknBody===>>>'+refreshToknBody);
        httpReqMail.setBody(refreshToknBody);
        try{
            httpResMail = httpMail.send(httpReqMail); 
            if(httpResMail.getStatusCode() == 200){
                System.debug(httpResMail.getBody()); 
            }else{
                String errorMessageMail = 'Unexpected Error while communicating with Google Calendar API. '
                    +'Status '+httpResMail.getBody()+' and Status Code '+httpResMail.getStatuscode();
                System.debug('Error ' + errorMessageMail);
                System.debug(httpResMail);
            }
        }catch(System.Exception e){            
            System.debug('#### Exception Executed '+e.getStackTraceString() + ' '+e.getMessage());
        } 
    }
}