public class SendEmailIfNotSeen {

    @InvocableMethod
    public static void sendEmail(List<Interview__c> interviewees){
        System.debug(interviewees[0].Contact_Email__c);
        
        DateTime interviewTime = DateTime.newInstance(interviewees[0].Date__c,interviewees[0].Time__c);
        System.debug(interviewTime);
        String tm = interviewTime.format('yyyy-MM-dd hh:mm:ss aa');
        
        String subjectGmail = 'Interview Status';
        // String bodyGmail = 'Dear '+ConObj.FirstName+',<br /><br />Thank you for Registration.<br />A representative will contact you shortly.<br /><br />Best always,<br />MV Clouds<br /><br /><a href="https://mvclouds.com">Mv Clouds</a>';
        //String bodyGmail = '<p style="font-family:verdana !important;">Dear '+interviewees[0].Contact_FirstName__c+',<br /><br />'+
            
        String bodyGmail = '<p style="font-family:verdana">'+
                	'Dear '+interviewees[0].Contact_FirstName__c+','+
                    '<br /><br/>'+                    
                    'We were scheduled to meet on google meeting at <b>'+tm+'</b> but you didn\'t make it so we rejected your application.'+
                    '<br /><br />'+
                    'If you had any personal emergency and couldn\'t join the meeting and you still interested then contact us. We will review your reason and then we will decide further.'+
                    '<br /><br />'+
                    'I wish you the best of luck in your future endeavours and hope we\'ll have a chance to meet again soon.'+
                    '<br /><br />'+
                    'Regards,'+
                    '</p>'+'<table style="font-family:verdana !important;margin-top:10px;">'+ 
                    '<tbody>'+
                        '<tr>'+
                            '<td rowspan="3" style="border-right:2px solid gray; padding-right:15px;"><img src="https://dharmikmv-dev-ed--c.ap4.content.force.com/servlet/servlet.ImageServer?id=0156F00000IzcHP&amp;oid=00D6F0000029IuY&amp;lastMod=1599120562000" style="height:70px"/></td>'+
                            '<td><strong style="font-family:verdana !important;">MV Clouds Private Limited</strong></td>'+
                        '</tr>'+
                        '<tr>'+
                            '<td>info@mvclouds.com || <a href="http://www.mvclouds.com" style="font-family:verdana !important;">www.mvclouds.com</a></td>'+
                        '</tr>'+
                        '<tr>'+
                            '<td>'+
                               '<p style="margin:0px!important;font-family:verdana !important;">D-404, The First Synthesis, B/H Keshav Baugh Party Plot,<br /> Shivalik High-Street, Ahmedabad - 380015</p>'+
                            '</td>'+
                        '</tr>'+
                    '</tbody>'+
                '</table>';
        
        String sendTo = interviewees[0].Contact_FirstName__c + '<'+ interviewees[0].Contact_Email__c +'>';
        
        GoogleGmailApi.sendGmail(subjectGmail,bodyGmail,sendTo);
        
        
    }
}