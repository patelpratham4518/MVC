public class TestingClass {

    public static void sendGmaill(){
        TestingClass.sendGmailWithAttachment('Testing Email','Hi Devansh Here <img width="400" heigh="400" src="cid:083.gif"/>','devansh.s@mvclouds.com','00P6F00003aRgk0UAC');
    }
    
    @future (callout=true)
    public static void sendGmailWithAttachment(String subjectMail,String bodyGmail,String sendTo, String attachment){
		
		String errorMessage ='';
                
        Attachment attach = [Select Id, Body,name,ContentType from Attachment Where Id =: attachment LIMIT 1];
        
        string before = 'From: MV Clouds <info@mvclouds.com>\n'+
                        'To: '+sendTo+'\n'+
            			'MIME-Version: 1.0\n'+
                        'Subject: '+subjectMail+'\n' +
                        'Content-Type: multipart/mixed; boundary="foo_bar_baz"\n\n'+
            			
            			 '--foo_bar_baz\n'+
                         'Content-Type: text/html; charset="UTF-8";\n'+
                         '\n\n'+bodyGmail+'\n\n'+
            
            			'--foo_bar_baz\n'+
            			'Content-Type: '+attach.ContentType+'; \n'+
			            'Content-ID: <083.gif>\n'+
                        'Content-Transfer-Encoding: base64\n'+
                        'Content-Disposition: inline; filename='+attach.name+'\n\n'+
            			EncodingUtil.base64Encode(attach.Body)+'\n\n--foo_bar_baz--';			


        Http httpMail = new Http();
        HttpRequest httpReqMail = new HttpRequest();
        HttpResponse httpResMail = new HttpResponse();
        httpReqMail.setEndpoint('callout:Gmail/upload/gmail/v1/users/me/messages/send?uploadType=multipart');
        httpReqMail.setMethod('POST');
        httpReqMail.setHeader('Content-Type', 'message/rfc822');
        httpReqMail.setHeader('Content-Length', '-1');
        String refreshToknBody = '{"userId":"me","raw":"'+before+'"}';
        system.debug(refreshToknBody);
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