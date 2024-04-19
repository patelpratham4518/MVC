public with sharing class LeaveControllerV2 {
    
    @AuraEnabled
    public static Date getOrgDate(){
        return Date.today();
    }


    // ================> Checking User in trainee Or Mentor <==================================
@AuraEnabled
public static string getUserType(string userid){
   System.debug('userid>>>'+userid);
   // id getContactId = [select id, contactId from User where id = : userid].contactId;
   Id getContactId = [SELECT id, contactId FROM User WHERE id =: UserInfo.getUserId()].contactId;
   System.debug('getContactId>>>'+getContactId);
   String userType = [SELECT Id, Name,ContactType__c FROM Contact WHERE Id =: getContactId].ContactType__c;
   System.debug(userType);
   return userType;    
}

// / ================> Return Contact List Associetd With Mentor <==================================
@AuraEnabled
public static List<Contact> getTrainneList(string userid){
   Id getContactId = [SELECT id, contactId FROM User WHERE id =: UserInfo.getUserId()].contactId;
   System.debug('getContactId>>>'+getContactId);
   Id getTeam = [SELECT Id, Name, Team__c FROM Contact WHERE Id =: getContactId].Team__c;
   System.debug('getTeam>>>'+getTeam);
   List<Contact> contactlist = [SELECT Id, Name FROM Contact WHERE Team__c =: getTeam AND ContactType__c = 'Developer'];
   System.debug('contactlist>>>'+contactlist);
   return contactlist;
}




// ================> FieldSet Value<==================================

// get records through field set component 
@AuraEnabled
public static String getFieldSet(String objectName, String fieldSetName){
    String result = '';
    List<String> pickListValuesList = new List<String>();
    try{
        SObjectType objToken = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult d = objToken.getDescribe();
        Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
        if (FsMap.containsKey(fieldSetName)){
            for (Schema.FieldSetMember f : FsMap.get(fieldSetName).getFields()){
                if (result != ''){
                    result += ',';
                }
                String jsonPart = '{';
                jsonPart += '"label":"' + f.getLabel()+'",';
                jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
                jsonPart += '"type":"' + (f.getType())+'",';
                jsonPart += '"apiname":"' + f.getFieldPath()+'"';
                if (String.valueOf(f.getType()) == 'PICKLIST'){
                    pickListValuesList = getDropDown(objectName, String.valueOf(f.getFieldPath()));
                    jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
                }
                jsonPart += '}';
                result += jsonPart;
            }
        }
        
    } catch (Exception e){
        result += e.getLineNumber()+' : ' + e.getMessage();
        System.debug('Error::' + e.getMessage());
        System.debug('Error At Line::' + e.getLineNumber());
    }
    return '[' + result + ']';
}

// get dropdown values
@AuraEnabled
public static List<String> getDropDown(String objName, String fieldName){
    List<String> pickListValuesList = new List<String>();
    try{
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objName);
        Schema.DescribeSObjectResult r = s.getDescribe();
        Map<String, Schema.SObjectField> fields = r.fields.getMap();
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }
    } catch (Exception e){
        throw new AuraHandledException(e.getMessage());
    }
    return pickListValuesList;
}

@AuraEnabled
public static List<String> getDaytypePicklist(){
    try{
        List<String> DayTypePicklist = new List<String>();
         Schema.DescribeFieldResult fieldResult = Leave__c.Day__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
             DayTypePicklist.add(pickListVal.getLabel());
         }     
         return DayTypePicklist;
    }
    catch (Exception e) {
        system.debug('error in class => '+e.getMessage());
        return null;
    }
}

@AuraEnabled
public static List<String> getLeavetypePicklist(){
    try{
        List<String> LeaveTypePicklist = new List<String>();
         Schema.DescribeFieldResult fieldResult = Leave__c.Leave_Type__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
            LeaveTypePicklist.add(pickListVal.getLabel());
         }     
         return LeaveTypePicklist;
    }
    catch (Exception e) {
        system.debug('error in class => '+e.getMessage());
        return null;
    }
}

@AuraEnabled
public static string SAVELeave(string inputFields, String UserId){
    try {
        id getContactId = [select id, contactId from User where id = : userid].contactId;
        Leave__c Leaves = (Leave__c)JSON.deserialize(inputFields, Leave__c.class);
        system.debug(Leaves);
        Leaves.Contact_Trainee__c = getContactId;
            insert Leaves;
            return 'Leave Apply Succesfull';
        
    } catch (Exception e) {
        system.debug('error in class => '+e.getMessage() + e.getLineNumber() + inputFields);
        return e.getMessage() + e.getLineNumber() + inputFields;
    }
}

// =========================== Contact Id Assign to Contact_traninee_c Using Trigger ==========================
public static void ContactAssign(List<Leave__c> ContactAssignMethod){

   Id getContactId = [SELECT id, contactId FROM User WHERE id =: UserInfo.getUserId()].contactId;
   // String mentorName = [SELECT id, Account.Name FROM Contact WHERE id =: getContactId].Account.Name;
     for(Leave__c lev : ContactAssignMethod){
       lev.Contact_Trainee__c = getContactId;
       
   }
}

public static void SendMailOnApplyLeave(List<Leave__c> SendMailDetail){

       try{
        List<Date> HolidayList =  new list<Date>();          
        List<string> ActualLeaves = new list<String>();     
        Date NextDateOnly;
        for(Leave__c lev : SendMailDetail){
            Integer DaysBetweenStartandEnd = lev.Start_Date__c.daysBetween(lev.End_Date__c);
            Integer ld;
            for(ld = 0; ld <= DaysBetweenStartandEnd; ld++){
                datetime LeaveDay = lev.Start_Date__c.addDays(ld);
                date LeaveDayDateOnly = LeaveDay.date();
                String leavedays = String.valueOf(LeaveDayDateOnly).removeEnd('00:00:00');

                datetime nextDay = lev.CreatedDate.addDays(ld);   
                NextDateOnly = nextDay.date();                                             
                for(Holiday Holi : [SELECT Id,Name,ActivityDate FROM Holiday]){           
                        HolidayList.add(Holi.ActivityDate);      
                    }
                if(LeaveDay.format('E') != 'Sat' && LeaveDay.format('E') != 'Sun' && !HolidayList.contains(LeaveDayDateOnly) ){
                    ActualLeaves.add(leavedays);  
                }                       
            }             
        }
           for(Leave__c MailDetail : SendMailDetail){
            
           String sd = String.valueOf(MailDetail.Start_Date__c).removeEnd('00:00:00');
           String ed = String.valueOf(MailDetail.End_Date__c).removeEnd('00:00:00');

           String CandidateName = [SELECT Id,Name FROM Contact WHERE ID =: MailDetail.Contact_Trainee__c].Name;
            String EmailSubject = CandidateName +' Leave Request';
           String bodygmail = 'Hi '+ 'Team '+', <br/> <br/>';
           bodygmail += 'Please accept sincere request of <b>'+ CandidateName + '</b> for these days off.<br/><br/>';
           bodygmail += 'FROM : <b>' +sd+ '</b><br/> ';
           bodygmail += 'TO : <b>' +ed+ '</b><br/>';
           bodygmail += 'Total Number of Leaves : <b>' +ActualLeaves.size() +'</b>.<br/> ';
           bodygmail += 'Day Type : <b>'+MailDetail.Day__c+'</b>.<br/>';
           bodygmail += 'Leave Type : <b>'+MailDetail.Leave_Type__c+'</b>.<br/>';
           bodygmail += 'Reason : <b>'+MailDetail.Reason__c  +'</b><br/>';
           bodygmail += '<br/>Have a great day ahead! <br/> ';
           bodygmail += ' <br/>Regards,';
            String EmailID = system.label.Email_Id_For_Approve_Leaves;
            System.debug(EmailID); 
            sendGmail(EmailSubject, bodygmail, EmailID);

            String UserName = ' Maitri';
            String Msg = '';
            Msg = '*'+CandidateName +'* is requesting *'+MailDetail.Leave_Type__c+'* of *'+MailDetail.Day__c+'* day from '+sd+ ' to '+ed+ ', with a total of *'+ActualLeaves.size()+'* days asked.\n Reason : *'+MailDetail.Reason__c+'*.';

            // List<String> MobileNo = system.label.mobile_No_For_Approve_Leaves.split(',');
            // System.debug(MobileNo);
            // for(String Mo : MobileNo){
            //     WhatsappIntegration.sendMessage(Mo, UserName, Msg);
            // }

            List<String> slackIdList = system.label.Slack_Id_For_Approve_Leaves.split(',');
            System.debug('slackIdList ==>' + slackIdList);
            for(String slackId : slackIdList){
                if (String.isNotBlank(slackId)) {	
                    SlackIntegration.sendSlackMessage(Msg, slackId);	
                }
            }
           }  
       } catch(Exception e){
           System.debug('Error->' + e.getStackTraceString()+ e.getMessage());

       }
    }
    
// =====================Sending Email On After Trigger Event For [Leave Status Update] =================================

// public static string SendMailLeaveUpdate(List<Leave__c> SendMailDetail){

//    try{
//        system.debug('Trainee Email id1');

//        for(Leave__c MailDetail : SendMailDetail){
        
//            if(MailDetail.Status__c == 'Approved' || MailDetail.Status__c == 'Rejected' ){
//                String sd = String.valueOf(MailDetail.Start_Date__c).removeEnd('00:00:00');
//                String ed = String.valueOf(MailDetail.End_Date__c).removeEnd('00:00:00');
               

//                String ContactEmailId = [SELECT Id,Email FROM Contact WHERE Id =: MailDetail.Contact_Trainee__c].Email;
//                system.debug(ContactEmailId);
//                String ContactName = [SELECT Id,Name FROM Contact WHERE Id =: MailDetail.Contact_Trainee__c].Name;
//                system.debug(ContactName);

//                String bodygmail = 'Hi '+ContactName+', <br/> <br/>';
//                // bodygmail += 'Ravi is Taking Leave on <b>' +Startdate+ '</b> to the <b>' +Enddate+ '</b>. ';
//                bodygmail += ' Your Leave For Date <b>' +sd+ '</b> to the <b>' +ed+ '</b> ';
//                bodygmail += 'Is <b>' +MailDetail.Status__c+ '</b>. ' ;
//                // bodygmail += '. Here is the Reason of their Leave. <br/><br/> <b>'+MailDetail.Reason__c  +'</b>';
//                // bodygmail += '<br/> <br/> <a href=\"https://mvclouds5-dev-ed.my.salesforce.com/'+MailDetail.ID+'" target="_blank"> Click here </a> is for approve or reject leave.';
//                bodygmail += '<br/> <br/> Thanks,';
//                bodygmail += '<br/>Mv Team';
               
//                system.debug('Trainee Email id : ' + ContactEmailId);
//                sendGmail('Leave Staus Update', bodygmail, ContactEmailId);
//                return ContactEmailId;
//            }
//        }
//        system.debug('Trainee Email id2');
//        return null;
       
//    } catch(Exception e){
//        System.debug('E->' + e.getMessage());
//        return e.getMessage();
//    }
// }

// ====================== call Out method class in above class for sending email ===================================
@future (callout=true) 
public static void sendGmail(String subjectMail,String bodyGmail,String sendTo){ 
   String errorMessage =''; 
   string before = 'From: avc <abc@abc.com>\n'+ 
   'To: '+sendTo+'\n'+ 
//    'To: '+'nirnavik@gmail.com,naviknirbhay@gmail.com'+'\n'+ 
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
//    ============================> Method to Return All Leave List For Trainee <==================================
@AuraEnabled
public static List<Leave__c> allLeavesList(String LeavesStatus, Integer Months, Integer years){
   try {
       List<Leave__c> allLeaves = new List<Leave__c>();
       Id getContactId = [SELECT id, contactId FROM User WHERE id =: UserInfo.getUserId()].contactId;
       if(Months != 0 && years != 0){
           allLeaves = [SELECT Id, Name, Start_Date__c, End_Date__c, Day__c, Reason__c, Contact_Trainee__c, Status__c,Leave_Type__c FROM Leave__c WHERE Status__c =: LeavesStatus AND Contact_Trainee__c =: getContactId AND CALENDAR_MONTH(Start_Date__c) =: Months AND CALENDAR_YEAR(Start_Date__c) =: years ORDER BY Name DESC];
           
       } else if (Months == 0 && years == 0){
           allLeaves = [SELECT Id, Name, Start_Date__c, End_Date__c, Day__c, Reason__c, Contact_Trainee__c, Status__c,Leave_Type__c FROM Leave__c WHERE Status__c =: LeavesStatus AND Contact_Trainee__c =: getContactId ORDER BY Name DESC];

       } else if (Months != 0 && years == 0){
           allLeaves = [SELECT Id, Name, Start_Date__c, End_Date__c, Day__c, Reason__c, Contact_Trainee__c, Status__c,Leave_Type__c FROM Leave__c WHERE Status__c =: LeavesStatus AND Contact_Trainee__c =: getContactId AND CALENDAR_MONTH(Start_Date__c) =: Months ORDER BY Name DESC];
           
       } else if (Months == 0 && years != 0){
           allLeaves = [SELECT Id, Name, Start_Date__c, End_Date__c, Day__c, Reason__c, Contact_Trainee__c, Status__c,Leave_Type__c FROM Leave__c WHERE Status__c =: LeavesStatus AND Contact_Trainee__c =: getContactId AND CALENDAR_YEAR(Start_Date__c) =: years ORDER BY Name DESC];

       }
       System.debug('allLeaves ==>' + allLeaves);
       return allLeaves;
   } catch (Exception e) {
       System.debug('#### Exception Called ==> '+e.getStackTraceString() + ' || '+e.getMessage()); 
       return null;
   }
}

//    ============================> Method to Return All Leave List For MENTOR <==================================
@AuraEnabled
public static List<Leave__c> allLeavesListForMentor(String LeavesStatus, String contactid, Integer Months, Integer years){
   try {
       List<Leave__c> allLeaves = new List<Leave__c>();
       if(Months != 0 && years != 0000){
           allLeaves = [SELECT Id, Name, Start_Date__c, End_Date__c, Day__c, Reason__c, Contact_Trainee__c, Status__c,Leave_Type__c FROM Leave__c WHERE Status__c =: LeavesStatus AND Contact_Trainee__c =: contactid AND CALENDAR_MONTH(Start_Date__c) =: Months AND CALENDAR_YEAR(Start_Date__c) =: years ORDER BY Name DESC];
           
       } else if (Months == 0 && years == 0000){
           allLeaves = [SELECT Id, Name, Start_Date__c, End_Date__c, Day__c, Reason__c, Contact_Trainee__c, Status__c,Leave_Type__c FROM Leave__c WHERE Status__c =: LeavesStatus AND Contact_Trainee__c =: contactid ORDER BY Name DESC];

       } else if (Months != 0 && years == 0000){
           allLeaves = [SELECT Id, Name, Start_Date__c, End_Date__c, Day__c, Reason__c, Contact_Trainee__c, Status__c,Leave_Type__c FROM Leave__c WHERE Status__c =: LeavesStatus AND Contact_Trainee__c =: contactid AND CALENDAR_MONTH(Start_Date__c) =: Months ORDER BY Name DESC];

       } else if (Months == 0 && years != 0000){
           allLeaves = [SELECT Id, Name, Start_Date__c, End_Date__c, Day__c, Reason__c, Contact_Trainee__c, Status__c,Leave_Type__c FROM Leave__c WHERE Status__c =: LeavesStatus AND Contact_Trainee__c =: contactid AND CALENDAR_YEAR(Start_Date__c) =: years ORDER BY Name DESC];

       }
       System.debug('allLeaves ==>' + allLeaves);
       return allLeaves;
   } catch (Exception e) {
       System.debug('#### Exception Called ==> '+e.getStackTraceString() + ' || '+e.getMessage()); 
       return null;
   }
}

//    ==========================> Method to update Status <===========================================

@AuraEnabled
public static String StatusUpdateMethod(String Status, Id LeaveID){
try{
   List<Leave__c> Levlist = new List<Leave__c>();
   Id getContactId = [SELECT id, contactId FROM User WHERE id =: UserInfo.getUserId()].contactId;
   for(Leave__c lv : [SELECT Id, Name, Contact_Trainee__c, Status__c FROM Leave__c WHERE Id =:LeaveID AND Status__c = 'Pending for Approval']){
           if(Status == 'Approving'){
               lv.Status__c = 'Approved';
               // return 'Leave Status Approved';
               } 
            else if (Status == 'Rejected'){
                   lv.Status__c = 'Rejected';
                   // return 'Leave Status Rejected';
               }
       Levlist.add(lv);
       // return null;

   }   update Levlist;
   return 'Status Update';
   } 
   catch(Exception e) {
       System.debug('#### Exception Called ==> '+e.getStackTraceString() + ' || '+e.getMessage()); 
       return e.getMessage();
   }
   
}

//============================Leave Delete Methods =================================================================
@AuraEnabled
public static String DeleteLeaves(String Id, String CancelReason){
    try {
        Leave__c lev = [SELECT Id,Name,Start_Date__c,End_Date__c,Day__c,Leave_Type__c,Reason__c,Contact_Trainee__c FROM Leave__c WHERE Id =: Id LIMIT 1];
        Delete lev;
        
        Contact leaveContact = [SELECT Id, Name, Email, MobilePhone, Slack_Id__c FROM Contact WHERE Id =: lev.Contact_Trainee__c];

        String ContactEmailId = leaveContact.Email;
        String ContactName = leaveContact.Name;
        String MobileNO = leaveContact.MobilePhone;
        String slackIdofApplyer = leaveContact.Slack_Id__c;

        String sd = String.valueOf(lev.Start_Date__c).removeEnd('00:00:00');
        String ed = String.valueOf(lev.End_Date__c).removeEnd('00:00:00');
        String bodygmail = 'Hi '+ContactName+',<br/><br/>';
        bodygmail += 'Greetings from MV Clouds! <br/><br/>';
        bodygmail += 'This mail is to notify you that your leave application for the Date : <b>'+sd+'</b> To : <b>'+ed+'</b>  has been cancelled sucessfully.<br/><br/>';
        bodygmail += 'Cancellation Reason : <b>'+CancelReason+'</b>.<br/><br/>';
        bodygmail += 'Have a great day ahead!<br/><br/>';
        bodygmail += 'Regards,';
        sendGmail('Leave Cancellation', bodygmail, ContactEmailId);

        String UserName = ContactName;
        String Msg = '';
        Msg += 'Your Leave for the date : '+sd+' to '+ed+' is Cancel Successfully.  ';
        // WhatsappIntegration.sendMessage(MobileNO,UserName ,Msg);
        if (String.isNotBlank(slackIdofApplyer)) {	
            SlackIntegration.sendSlackMessage(Msg, slackIdofApplyer);
        }
        
        //Email to Management
        String EmailSubject = ContactName+' leave cancellation';
        String GmailBody = 'Hi Team,<br/><br/>';
        GmailBody += 'Hope you are doing well!<br/><br/>';
        GmailBody += 'Please be noted that the leave application of <b>'+ ContactName +'</b> for the period from <b>'+sd+'</b> to <b>'+ed+'</b> has been cancelled.<br/><br/>';
        GmailBody += 'Cancellation Reason : <b>'+CancelReason+'</b>.<br/><br/>';
        GmailBody += 'Have a great day ahead!<br/><br/>';
        GmailBody += 'Regards,';
        String EmailID = system.label.Email_Id_For_Approve_Leaves;
        System.debug(EmailID); 
        sendGmail(EmailSubject, GmailBody, EmailID);

        String UserName2 = ' Maitri';
        String Msg1 = '';
        Msg1 += '*'+ContactName+'*’s ';
        Msg1 += 'Leave for the date : '+sd+' to '+ed+' has been cancelled  ';

        // List<String> MobileNo1 = system.label.mobile_No_For_Approve_Leaves.split(',');
        //     for(String Mo : MobileNo1){
        //         WhatsappIntegration.sendMessage(Mo,UserName2, Msg1);
        //     }

        List<String> slackIdList = system.label.Slack_Id_For_Approve_Leaves.split(',');
        System.debug('slackIdList ==>' + slackIdList);
        for(String slackId : slackIdList){
            if (String.isNotBlank(slackId)) {	
                SlackIntegration.sendSlackMessage(Msg1, slackId);	
            }
        }
        
        return CancelReason;
    } catch (Exception e) {
        System.debug('#### Exception Called ==> '+e.getStackTraceString() + ' || '+e.getMessage()); 
        return e.getMessage();
    }
}

// ==================================> 1 + 2 Scenario <==============================================================

public static void onePlusTwoScenarionMethod(List<Leave__c> levlist){
   try{

   List<String> Leaves = new List<String>();             // Store Leaves eligible For 1+2 Scenario....
   List<Date> HolidayList =  new list<Date>();          // Store to Holidays....
   List<string> ActualLeaves = new list<String>();      // Store Actual Leave By Excluding Weekend And Holiday 
   Date NextDateOnly;
   
       for(Leave__c lev : levlist){
           if(lev.Leave_Type__c != 'Sick Leave'){

               System.debug('Start Date => ' + lev.Start_Date__c);
               System.debug('Apply Date => ' + lev.CreatedDate);
               
               // Date StrtDate = lev.Start_Date__c;
               
               Date CreateDate = lev.CreatedDate.date();   
               
               Integer DaysBetweenStartandEnd = lev.Start_Date__c.daysBetween(lev.End_Date__c);
               System.debug(' Total Day Between Leaves : ' + (DaysBetweenStartandEnd + 1));
               Integer TotalLeaves = 0;                        // To count Only Working Day Leaves...
               Integer BeforeDay = 0;
               Integer ld;
               for(ld = 0; ld <= DaysBetweenStartandEnd; ld++){
                   
                   datetime LeaveDay = lev.Start_Date__c.addDays(ld);

                   date LeaveDayDateOnly = LeaveDay.date();                                            
                   System.debug('Leave Day : ' + LeaveDayDateOnly);
                   String leavedays = String.valueOf(LeaveDayDateOnly).removeEnd('00:00:00');
                   
                   Integer DayBWLeaveAndCraeted = CreateDate.daysBetween(LeaveDayDateOnly);             // Calculating Days Between Creates(ApplyDate) & Leave Date;
                   // System.debug('DayBWLeaveAndCraeted' + DayBWLeaveAndCraeted);
                   
                   Integer day = 0;                                                                // To calculating Total Working Days;

                   for(Integer i=0; i<DayBWLeaveAndCraeted; i++){                 
                       datetime nextDay = lev.CreatedDate.addDays(i);                       // Create Leave Date For Evary Leave Day
                       day = day +1 ;                                                       // Adding Working Day Over Every Iteration
                       if(nextDay.format('E') == 'Sat'){                                   // It Is checking day Is Saturday Or Not...
                           day = day-1;                                                     // If Day Is Saturday It Minus 1 Day from Total Working Days...  
                       } else if (nextDay.format('E') == 'Sun'){                           // It Is checking day Is Sunday Or Not...
                           day = day-1;                                                     // If Day Is Saturday It Minus 1 Day from Total Working Days...
                       }      
                    //    Hodilday Portion ------------------------------------------------------
                          NextDateOnly = nextDay.date();                                                // Convert Next Day Date In Date From DateTime , So we Can Compare it With Holidat ActivityDate
                           for(Holiday Holi : [SELECT Id,Name,ActivityDate FROM Holiday]){               // Interating Over All Holiday....
                                   // System.debug('Holiday Activity Date : '+ Holi.ActivityDate);
                                   HolidayList.add(Holi.ActivityDate);
                                   if (NextDateOnly == Holi.ActivityDate){                                 // Checking Next day Date Is Similar to Holidat Activity Date Or Not...
                                            day = day-1;                                                   // If Next Day Date Is Similar To Holiday Date It Minus 1 Day from Total Working Days....
                                       }       
                               }
                           } 
                           System.debug('Total Working Days Between Apply Day And Leave  is '+ day);
                           // Count Leave Day If Leave Day Is Not Sat,Sun or Holiday
                           if(lev.Day__c == 'Full' && LeaveDay.format('E') != 'Sat' && LeaveDay.format('E') != 'Sun' && !HolidayList.contains(LeaveDayDateOnly) ){
                            TotalLeaves = TotalLeaves + 1;
                            ActualLeaves.add(leavedays);                         
                            System.debug('You Have Apply for Leave Before Only '+ day + ' Working Days So your Leave on Date '+ leavedays +' Will Be Counted In 1+2 Scenario...' );
                           if(day < 5){
                                TotalLeaves = TotalLeaves + 2;                   // ADD 2 MORE LEAVES IN TOTAL LEAVES FOR 1+2
                                Leaves.add(leavedays);                             // Add These Leave Applie before 5 working days in 1+2 Leaves
                               }
                               BeforeDay = 5;
                           } 
                           else if(lev.Day__c != 'Full' && LeaveDay.format('E') != 'Sat' && LeaveDay.format('E') != 'Sun'){ 
                            TotalLeaves = TotalLeaves + 1;
                            ActualLeaves.add(leavedays);    
                            System.debug('You Have Apply for Half Leave Before Only '+ day + ' Working Days So your Leave on Date '+ leavedays +' Will Be Counted In 1+2 Scenario...' );
                           if(day < 3){
                                TotalLeaves = TotalLeaves + 2;
                                Leaves.add(leavedays);
                               }
                               BeforeDay = 3;
                           }   
                   } 
                       System.debug('Leave In 1+2 Scenario : '+ Leaves );
                       System.debug('total leaves : '+ TotalLeaves);

                       if(Leaves.Size() != 0){
                               String ContactEmailId = [SELECT Id,Email FROM Contact WHERE Id =: lev.Contact_Trainee__c].Email;
                               system.debug(ContactEmailId);
                               String ContactName = [SELECT Id,Name FROM Contact WHERE Id =: lev.Contact_Trainee__c].Name;
                               system.debug(ContactName);

                               String bodygmail = 'Hi '+ContactName+',<br/><br/>';
                               bodygmail += 'I hope you are doing well! <br/><br/>';
                               bodygmail += '• I have received your request for Leaves for date : ';
                               bodygmail += '<b>' + ActualLeaves + '</b> <br/>';
                               bodygmail += '• Please be informed that the 1+2 rule will be applicable to your leaves.<br/>';
                               bodygmail += '• Leaves for date : <b>'+Leaves+'</b>  will be considered in 1+2 scenario <br/><br/>';
                               bodygmail += '<b> Note : </b>The total number of your leave days as per our company’s policy is : <b>'+TotalLeaves+'</b>.<br/><br/>';
                               bodygmail += 'Have a great day ahead!<br/><br/>';
                               bodygmail += 'Regards,';
                               
                               system.debug('Trainee Email id : ' + ContactEmailId);
                               sendGmail('Leave Application Status', bodygmail, ContactEmailId);
                       }
               }
           }
           }
           catch(Exception e) {
               System.debug('#### Exception Called ==> '+e.getStackTraceString() + ' || '+e.getMessage()); 
           }
       }   

       //=======================Set Leave Type picklis value Based On Apply days before 5 day or not =================================================
       @AuraEnabled
       public static List<String> SetLeaveTypePicklist(Date Cd,Date Ld){
        try{
                    // Date CreateDate = date.newInstance(2023, 03, 23);
                    Date CreateDate = date.valueOf(Cd);
                Datetime CreatedDateTime = CreateDate;
                    // Date LeaveDateOnly = date.newInstance(2023, 03, 31);
                List<Date> HolidayList =  new list<Date>();   
                Integer DayBWLeaveAndCraeted = CreateDate.daysBetween(date.valueOf(Ld));   
                Integer day = 0;                                                               
                    for(Integer i=0; i<DayBWLeaveAndCraeted; i++){                 
                        datetime nextDay = CreatedDateTime.addDays(i);                       
                        day = day +1 ;                                                      
                            if(nextDay.format('E') == 'Sat'){                                   
                                day = day-1;                                                    
                            } else if (nextDay.format('E') == 'Sun'){                          
                                day = day-1;                                                    
                            }  
                        Datetime NextDateOnly = nextDay.date();
                            for(Holiday Holi : [SELECT Id,Name,ActivityDate FROM Holiday]){            
                                        HolidayList.add(Holi.ActivityDate);
                                        if (NextDateOnly == Holi.ActivityDate){                                 
                                                    day = day-1;                                                  
                                            }       
                                    }
                        } 
                //  System.debug('Total Working Days Between Apply Day And Leave  is '+ day);
                 
                 List<String> LeaveTypePicklist = new List<String>();
                 Schema.DescribeFieldResult fieldResult = Leave__c.Leave_Type__c.getDescribe();
                 List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                 for( Schema.PicklistEntry pickListVal : ple){
                     LeaveTypePicklist.add(pickListVal.getLabel());
                    }     
                    if(day < 5){
                        LeaveTypePicklist.remove(0);   // Remove Planned leave if day is less than 5
                    }
                    else{
                        LeaveTypePicklist.remove(2);   // Remove unplanned leave if day is grater than or equal to 5
                    }
                    
                    //  System.debug('LeaveTypePicklist : '+LeaveTypePicklist);
                    return LeaveTypePicklist;
                }
            catch(Exception e) {
                System.debug('#### Exception Called ==> '+e.getStackTraceString() + ' || '+e.getMessage()); 
                List<String> error = new List<String>();
                error.add(e.getMessage());
                return error;
            }
            }
}