public class ContactTriggerHandler {
    
    List<Contact> recordNewList = new List<Contact>();
    List<Contact> recordOldList = new List<Contact>();
    Map<Id, Contact> recordNewMap = new Map<Id, Contact>();
    Map<Id, Contact> recordOldMap = new Map<Id, Contact>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = false;
    
    public ContactTriggerHandler(List<Contact> newList, List<Contact> oldList, Map<Id, Contact> newMap, Map<Id, Contact> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
        this.recordNewList = newList;
        this.recordOldList = oldList;
        this.recordNewMap = newMap;
        this.recordOldMap = oldMap;
        this.isInsert = isInsert;
        this.isUpdate = isUpdate;
        this.isDelete = isDelete;
        this.isUndelete = isUndelete;
    }
    
    public void BeforeInsertEvent(){}
    
    public void BeforeUpdateEvent(){}
    
    public void BeforeDeleteEvent(){}
    
    public void AfterInsertEvent(){

        Id recordtypeIdOfCandidate = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();

        for(Contact c: recordNewList){
             if(c.Apply_through_form__c == false && c.RecordTypeId ==recordtypeIdOfCandidate){
            sendEmail(c);
             }
        // }
        }
    }
    
    public void AfterUpdateEvent(){
    }
    
    public void AfterDeleteEvent(){}
    
    public void AfterUndeleteEvent(){}
    
    public void sendEmail(Contact con){
        // List<Interview__c> interviewees = new List<Interview__c>();
        // System.debug(interviewees);
        // Id ids = interviewees[0].Id;        
        // System.debug(ids);

        // Interview__c interviewDetails = [SELECT Id, Date__c, Job_Posting__r.Job_Name__c,Interview_DateTime__c, Reporting_Date__c,Time__c, Result__c, Interviewer__c, Interviewer__r.Name ,Interviewer__r.Email__c ,  Interviewer_Email__c,  RecordType.Name, Job_Application__c, Job_Application__r.Job_Posting__c, Job_Application__r.Job_Posting__r.Job_Name__c, Job_Application__r.Contact__r.FirstName, Job_Application__r.Contact__r.LastName, Job_Application__r.Contact__r.Name, Job_Application__r.Contact__r.Email,Google_Event_ID__c from Interview__c Where Id =:ids LIMIT 1];
        // Contact con = new Contact();
        System.debug(con.Name);
        System.debug(con.Email);
        String subjectGmail = 'Your application at MV Clouds has been successfully received';

        String bodyGmail = 'Dear '+  con.FirstName + ' ' +con.LastName + ',' + '</p>'+ '<p style="font-family:verdana !important;">'+
                            'Thank you for submitting your application to <b>MV Clouds Private Limited!</b>'+
                            ' We have successfully received your application for ' + con.Job_Name__c + '.</p>' +
                            '<p style="font-family:verdana !important;">' +
                            'We appreciate your interest in <a href="https://mvclouds.com">MV Clouds</a>, we are reviewing all applications carefully, and if you are selected for the first round of interviews, our HR will contact you.</p>' +

                            '<p style="font-size:12px;font-family:verdana;">'+
                            '[Please note that submitting an incomplete application with missing document or information will cause a delay in processing. We\'ll send you an email if there are any missing documents that we\'ll need you to submit when we\'ve started processing your application and documentation.]'
                            +'</p>'+

                            '<p style="font-family:verdana !important;">'+
                            'Please respond to this email if you have any questions.</p>' +
                            '<p style="font-family:verdana !important;">'+
                            'Regards,</p>'+

                            '<table style="font-family:verdana !important;margin-top:10px;">'+
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
        // String subjectGmail = 'Thank you for applying';
        //     // String bodyGmail = 'Dear '+ConObj.FirstName+',<br /><br />Thank you for Registration.<br />A representative will contact you shortly.<br /><br />Best always,<br />MV Clouds<br /><br /><a href="https://mvclouds.com">Mv Clouds</a>';
        //     String bodyGmail = '<p style="font-family:verdana !important;padding:0px!important;margin:0px!important">Dear '+con.FirstName+',<br /><br />'+
        //             'Thank you for taking time to apply at <b>MV Clouds Private Limited!</b> <br/><br/>'+
        //                 'We appericiate your interest in <a href="www.mvclouds.com">MV Clouds</a>, we are looking all application very closely and one of our team member will call you if you are shortlisted for the first round of interview.<br /><br /> '+
        //                 'If you have any questions please reply back to this email.<br/><br/>'+
        //                 'Regards,'+
                        
        //                 '<table style="font-family:verdana !important;margin-top:10px;">'+ 
        //                     '<tbody>'+
        //                         '<tr>'+
        //                             '<td rowspan="3" style="border-right:2px solid gray; padding-right:15px;"><img src="https://dharmikmv-dev-ed--c.ap4.content.force.com/servlet/servlet.ImageServer?id=0156F00000IzcHP&amp;oid=00D6F0000029IuY&amp;lastMod=1599120562000" style="height:70px"/></td>'+
        //                             '<td><strong style="font-family:verdana !important;">MV Clouds Private Limited</strong></td>'+
        //                         '</tr>'+
        //                         '<tr>'+
        //                             '<td>info@mvclouds.com || <a href="http://www.mvclouds.com" style="font-family:verdana !important;">www.mvclouds.com</a></td>'+
        //                         '</tr>'+
        //                         '<tr>'+
        //                             '<td>'+
        //                                '<p style="margin:0px!important;font-family:verdana !important;">D-404, The First Synthesis, B/H Keshav Baugh Party Plot,<br /> Shivalik High-Street, Ahmedabad - 380015</p>'+
        //                             '</td>'+
        //                         '</tr>'+
        //                     '</tbody>'+
        //                 '</table><p>';
                        
            String sendTo = con.FirstName + ' ' +con.LastName + '<'+ con.Email +'>';
            System.debug(con.Name);
            System.debug(con.Email);
            System.debug(sendTo);
            
            GoogleGmailApi.sendGmail(subjectGmail,bodyGmail,sendTo);
    }
    

}