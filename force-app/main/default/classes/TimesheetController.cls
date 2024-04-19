public without sharing class TimesheetController {

    // FOR CHECK USER IS MENTOR OR TRAINEE
    @AuraEnabled(cacheable=true)
    public static string checkuser(){
        try {

            Id contactid = [SELECT Name, ContactId FROM User WHERE Id =: UserInfo.getUserId()].ContactId;
            return [SELECT Id, Name, ContactType__c FROM Contact WHERE Id =: contactid].ContactType__c;
        } catch (Exception e) {
            System.debug('Error Message =>'+e.getMessage());
            return e.getMessage();
        }
    }


    // USED FOR GET TIMESHEET DETAIL DATA ON TIMESHEET PAGE
    @AuraEnabled
    public static List<Timesheet_Detail__c> getTimesheetData(String contactid, Date seldate){
        
        try {
            String recordid;
            if(contactid.length() != 0){
                recordid = contactid;
            } else {
                recordid = [SELECT Name, ContactId FROM User WHERE Id =: UserInfo.getUserId()].ContactId;
            }
            System.debug('selDate=->'+seldate);
            System.debug('date.valueOf(seldate)==>'+date.valueOf(seldate));
            return [SELECT Id, Name, Task_Name__c, Task_Description__c, Date__c, Start_Time__c, End_Time__c, Comments__c, Timesheet__c, Status__c,Timesheet__r.Daily_Status__c,Timesheet__r.Contact__r.Name FROM Timesheet_Detail__c WHERE Date__C =: date.valueOf(seldate) AND Timesheet__r.Contact__c =: recordid ORDER BY CreatedDate ASC];
        } catch (Exception e) {
            System.debug('Error Message =>'+e.getMessage());
            return null;
        }
    }

    // USED FOR CREATING TIMESHEET RECORD ON TIMESHEET PAGE
    @AuraEnabled
    public static String createTimesheetRecord(String timesheetdata, String userid){

        try{    
            System.debug('timesheetdata-==>'+timesheetdata);
            timesheetwrap wrapdata = (timesheetwrap)JSON.deserialize(timesheetdata,timesheetwrap.class);
            
            System.debug('Wrap ==>'+wrapdata);
            id getContactId = [select id, contactId from User where id = : userid].contactId;
            Id getTeam = [SELECT Id, Name, Team__c FROM Contact WHERE Id =: getContactId].Team__c;
            List<Timesheet__c> tslist = [SELECT Id, Name, Date__c FROM Timesheet__c WHERE Date__c =: wrapdata.taskdate and Contact__C =: getContactId];
            System.debug('tslist==>'+tslist);
            System.debug('tslist==>'+tslist.size());

            id timesheetid ;

            if(tslist.size() == 0 ){
                Timesheet__c ts = new Timesheet__c();
                ts.Date__c = wrapdata.taskdate;
                ts.Team__c = getTeam;
                ts.Contact__c = getContactId;
                insert ts;
                timesheetid = ts.Id;
            }else{
                timesheetid = tslist[0].Id;
            }

            System.debug('wrapdata.startTime>>>'+wrapdata.startTime);
            System.debug('wrapdata.taskdate>>'+wrapdata.taskdate);
            List<Timesheet_Detail__c> td = [SELECT Id FROM Timesheet_Detail__c WHERE Start_Time__c=:wrapdata.startTime AND Timesheet__c=:timesheetid AND Date__c=:wrapdata.taskdate LIMIT 1];
            if(td.size()==0){ 

                Timesheet_Detail__c	tsdetail = new Timesheet_Detail__c();
                tsdetail.Task_Name__c = wrapdata.taskname;
                tsdetail.Task_Description__c = wrapdata.taskdesc;
                tsdetail.Date__c = wrapdata.taskdate;
                tsdetail.Start_Time__c = wrapdata.startTime;
                tsdetail.End_Time__c = wrapdata.endTime;
                tsdetail.Comments__c = wrapdata.comments;
                tsdetail.Timesheet__c = timesheetid;
                insert tsdetail;
                return 'Timesheet Created Successfully';
            }
            else{
                return 'Please Select Different Start Time';
            }
        } catch(Exception e) {
            String errormsg = e.getMessage() + ' ---- ' +e.getLineNumber();
            System.debug('Errpr Message===>'+e.getMessage());
            return errormsg;
        }
    }

    //Approve/Reject Timesheet
    @AuraEnabled
    public static String updateStaus(String action, String tdId, String rejectedreason ){

        String returnmessage = '';
        try {
            Timesheet_Detail__c td = [SELECT Id, Status__c, Rejected_Reason__c, CreatedDate FROM Timesheet_Detail__c WHERE Id=:tdId];
            if(td != null){
                Integer counter = 0;
                String dayformat = td.CreatedDate.format('EEEE');
                DateTime TodayDate = Date.today();
                if (dayformat == 'Friday') {
                    counter+=3;
                } else if(dayformat == 'Saturday') {
                    counter+=2;
                } else {
                    counter+=1;
                }
                if (td.CreatedDate.addDays(counter) >= TodayDate) {
                    td.Status__c = action;
                    td.Rejected_Reason__c = rejectedreason;
                    update td;
                    returnmessage = 'Timesheet updated Successfully!';
                } else{
                    returnmessage = 'You Cannot '+action+' Timesheet!';
                }
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
            returnmessage = e.getMessage();
        }
        return returnmessage;
    }

    @AuraEnabled
    public static String submittimesheet(){

        try{
            Id conId = [SELECT Id,ContactId FROM User where Id=: UserInfo.getUserId()].contactId;
            System.debug('con>>'+conId);

            Timesheet__c timesheet = [SELECT Id,Team__c,Contact__c,Date__c,Team__r.Lead_Name__c,Contact__r.Name,Team__r.Lead_Email__c, Daily_Status__c FROM Timesheet__c WHERE Contact__c=:conId AND Date__c =: Date.today()];
            timesheet.Daily_Status__c = true;
            update timesheet;
            System.debug('timesheet>>>'+timesheet);

            List<Timesheet_Detail__c> tdlst = [SELECT Id,Timesheet__c FROM Timesheet_Detail__c WHERE Timesheet__c=:timesheet.Id AND Date__c =: Date.today()];
            List<Timesheet_Detail__c> tdlstnew = new List<Timesheet_Detail__c>();
            for(Timesheet_Detail__c td : tdlst){
                td.Status__c = 'Pending for approval';      
                tdlstnew.add(td);
            }        
            update tdlstnew;

            String bodygmail = 'Hi '+timesheet.Team__r.Lead_Name__c+', <br/> <br/>';
            bodygmail += +timesheet.Contact__r.Name+ ' has submitted the timesheet <b>';
            bodygmail += '<br/>Login to the portal for approve or reject Timesheet.';
            bodygmail += '<br/> <br/> Thanks,';
            bodygmail += '<br/>Mv Team';
            sendGmail('Timesheet Submitted',bodyGmail,timesheet.Team__r.Lead_Email__c);
            return 'success';

        }catch(Exception e){
            System.debug('Exception>>>'+e);
            return e.getMessage();
        }

    }   

    @AuraEnabled
    public static String deleteTimesheetRecord(String timesheetdetailId){

        try{
            Timesheet_Detail__c timesheet = [SELECT Id,Date__c FROM Timesheet_Detail__c WHERE Id=:timesheetdetailId AND Date__c =: Date.today()];
            delete timesheet;
            return 'Success';
        }catch(Exception e){
            System.debug('Exception>>>'+e);
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static void updateTimesheetDetailRecord(String timesheetdata,String timesheetdetailId){

        try{

            timesheetwrap wrapdata = (timesheetwrap)JSON.deserialize(timesheetdata,timesheetwrap.class);
            System.debug('Wrap ==>'+wrapdata);

            // Timesheet_Detail__c timesheet = [SELECT Id, Name, Task_Name__c, Task_Description__c, Date__c, Start_Time__c, End_Time__c, Comments__c, Timesheet__c, Status__c FROM Timesheet_Detail__c WHERE Id=:timesheetdetailId AND Date__c =: Date.today()];
            Timesheet_Detail__c timesheet = [SELECT Id, Name, Task_Name__c, Task_Description__c, Date__c, Start_Time__c, End_Time__c, Comments__c, Timesheet__c, Status__c FROM Timesheet_Detail__c WHERE Id=:timesheetdetailId ];
            
            timesheet.Task_Name__c = wrapdata.taskname;
            timesheet.Task_Description__c = wrapdata.taskdesc;
            timesheet.Date__c = wrapdata.taskdate;
            timesheet.Start_Time__c = wrapdata.startTime;
            timesheet.End_Time__c = wrapdata.endTime;
            timesheet.Comments__c = wrapdata.comments;

            update timesheet;
        }catch(Exception e){
            System.debug('Exception>>>'+e);
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

    @AuraEnabled
    public static Date getOrgDate(){
        return Date.today();
    }


    public class timesheetwrap{
        
        @AuraEnabled
        public String taskname {get;set;}
        @AuraEnabled
        public String taskdesc {get;set;}
        @AuraEnabled
        public Date taskdate {get;set;}
        @AuraEnabled
        public Time startTime {get;set;}
        @AuraEnabled
        public Time endTime {get;set;}
        @AuraEnabled
        public String comments {get;set;}
    }
}