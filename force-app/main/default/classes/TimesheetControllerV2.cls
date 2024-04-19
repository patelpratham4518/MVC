public without sharing class TimesheetControllerV2 {

    @AuraEnabled
    public static string getUserType(string userid){
        System.debug('userid>>>'+userid);
        id getContactId = [select id, contactId from User where id = : userid].contactId;
        System.debug('getContactId>>>'+getContactId);
        String userType = [SELECT Id, Name,ContactType__c FROM Contact WHERE Id =: getContactId].ContactType__c;
        System.debug(userType);
        return userType;    
    }

    @AuraEnabled(cacheable = true)
    public static List<String> getUserTypeMts(string userid){
        System.debug('userid>>>'+userid);
        id getContactId = [select id, contactId from User where id = : userid].contactId;
        System.debug('getContactId>>>'+getContactId);
        List<Contact> userType = [SELECT Id, Name,ContactType__c FROM Contact WHERE Id =: getContactId];
        List<String> userList = new List<String>();

        userList.add(userType[0].Name);
        userList.add(userType[0].ContactType__c);

        System.debug(userType);
        return userList;    
    }

    @AuraEnabled
    public static List<Timesheet_Detail__c> getMentorTimesheetData(String userId ,Date seldate , String statusValue ){

        String recordid = [SELECT Name, ContactId FROM User WHERE Id =: userId].ContactId;
        System.debug(recordid);
        List<Timesheet_Detail__c> timesheetlist = new List<Timesheet_Detail__c>();
        if (statusValue == 'Pending') {
            System.debug('statusValue==>'+statusValue);
            timesheetlist = [SELECT Id,Name, Task_Name__c, Task_Description__c, Date__c,Project__c,Project__r.Name,Project__r.Project_Name__c,Requirement__c,Requirement__r.Name, Start_Time__c, End_Time__c,hours__c, Comments__c,TicketNumber__c, Timesheet__c, Status__c,Timesheet__r.Daily_Status__c,Timesheet__r.Contact__r.Name FROM Timesheet_Detail__c WHERE Date__C =: date.valueOf(seldate) AND Timesheet__r.Contact__c =: recordid AND (Status__c=null OR Status__c ='Pending for approval') ORDER BY Start_Time__c ASC];
            System.debug('timesheetlist==>'+timesheetlist);
            return timesheetlist;
        }
        else {
            timesheetlist = [SELECT Id,Name, Task_Name__c, Task_Description__c, Date__c,Project__c, TicketNumber__c,Project__r.Name,Project__r.Project_Name__c,Requirement__c,Requirement__r.Name, Start_Time__c,hours__c, End_Time__c, Comments__c, Timesheet__c, Status__c,Timesheet__r.Daily_Status__c,Timesheet__r.Contact__r.Name FROM Timesheet_Detail__c WHERE Date__C =: date.valueOf(seldate) AND Timesheet__r.Contact__c =: recordid AND Status__c =: statusValue ORDER BY Start_Time__c ASC];
            return timesheetlist;
        }
    }


    @AuraEnabled
    public static List<Timesheet_Detail__c> getTimesheetData(String userId , String selectedContactId,Date seldate , String statusValue , String project , String contactType ){
        try {

            String recordid;
            if (userId.length() != 0) {
                System.debug('userId==>'+userId);
                recordid = [SELECT Name, ContactId FROM User WHERE Id =: userId].ContactId;
                System.debug(recordid);
            } else { 
                System.debug('UserInfo.getUserId()==>'+UserInfo.getUserId());
                recordid = [SELECT Name, ContactId FROM User WHERE Id =: UserInfo.getUserId()].ContactId;
            }
            if (contactType == 'CEO'){
                System.debug('CEO');
            }
            if (contactType == 'Senior Developer') {

                List<String> projectlist = new List<String>();
                if (project == 'All') {
                    id contactId = [select id, contactId from User where id = : UserInfo.getUserId()].contactId;
                    System.debug('contactId>>>'+contactId);
                    List<Project__c> projectss = [SELECT Id, Name, Project_Type__c FROM project__c WHERE Project_Lead__c = :contactId];
                    for (Project__c project1 : projectss) {
                        projectlist.add(project1.Id);
                    }
                }
                else if (project != '' ) {
                    projectlist.add(project);
                }

                System.debug('Lead');
                if (selectedContactId == 'All') {
                    List<Contact> teamMembers = getTrainneList(project , seldate);
                    if (statusValue == 'Pending') {
                        System.debug('statusValue==>'+statusValue);
                        List<Timesheet_Detail__c> tsd = [SELECT Id,Name, Task_Name__c, Task_Description__c, Date__c,Requirement__c,Requirement__r.Name,Project__c,Project__r.Name,Project__r.Project_Name__c, Start_Time__c, End_Time__c,hours__c, Comments__c,TicketNumber__c, Timesheet__c, Status__c,Timesheet__r.Daily_Status__c,Timesheet__r.Contact__r.Name FROM Timesheet_Detail__c WHERE Date__C =: date.valueOf(seldate) AND Timesheet__r.Contact__c IN : teamMembers AND project__c IN: projectlist ORDER BY Start_Time__c ASC];
                        System.debug('tsd==>'+tsd);
                        return tsd;
                    }
                    else {
                        List<Timesheet_Detail__c> tsd = [SELECT Id,Name, Task_Name__c, Task_Description__c, Date__c,Requirement__c,Requirement__r.Name,Project__c, TicketNumber__c,Project__r.Name,Project__r.Project_Name__c, Start_Time__c,hours__c, End_Time__c, Comments__c, Timesheet__c, Status__c,Timesheet__r.Daily_Status__c,Timesheet__r.Contact__r.Name FROM Timesheet_Detail__c WHERE Date__C =: date.valueOf(seldate) AND Timesheet__r.Contact__c IN : teamMembers AND project__c IN: projectlist ORDER BY Start_Time__c ASC];
                        return tsd;
                    }
                }else if (statusValue != null && statusValue != '' && selectedContactId != 'All') {
                    System.debug(2);
                    if (statusValue == 'Pending') {
                        System.debug('statusValue==>'+statusValue);
                        List<Timesheet_Detail__c> tsd = [SELECT Id,Name, Task_Name__c, Task_Description__c, Date__c,Project__c,Requirement__c,Requirement__r.Name,Project__r.Name,Project__r.Project_Name__c, Start_Time__c, End_Time__c,hours__c, Comments__c,TicketNumber__c, Timesheet__c, Status__c,Timesheet__r.Daily_Status__c,Timesheet__r.Contact__r.Name FROM Timesheet_Detail__c WHERE Date__C =: date.valueOf(seldate) AND Timesheet__r.Contact__c =: selectedContactId AND project__c IN: projectlist  ORDER BY Start_Time__c ASC];
                        System.debug('tsd==>'+tsd);
                        return tsd;
                    }
                    else {
                        List<Timesheet_Detail__c> tsd = [SELECT Id,Name, Task_Name__c, Task_Description__c, Date__c,Requirement__c,Requirement__r.Name,Project__c, TicketNumber__c,Project__r.Name,Project__r.Project_Name__c, Start_Time__c,hours__c, End_Time__c, Comments__c, Timesheet__c, Status__c,Timesheet__r.Daily_Status__c,Timesheet__r.Contact__r.Name FROM Timesheet_Detail__c WHERE Date__C =: date.valueOf(seldate) AND Timesheet__r.Contact__c =: selectedContactId AND project__c IN: projectlist ORDER BY Start_Time__c ASC];
                        return tsd;
                    }
                }else {
                    List<Timesheet_Detail__c> tsd = [SELECT Id,Name, Task_Name__c, Task_Description__c, Date__c,Requirement__c,Requirement__r.Name,Project__c, TicketNumber__c,Project__r.Name,Project__r.Project_Name__c, Start_Time__c,hours__c, End_Time__c, Comments__c, Timesheet__c, Status__c,Timesheet__r.Daily_Status__c,Timesheet__r.Contact__r.Name FROM Timesheet_Detail__c WHERE Date__C =: date.valueOf(seldate) AND Timesheet__r.Contact__c =: selectedContactId AND project__c IN: projectlist ORDER BY Start_Time__c ASC];
                    return tsd;
                }
            } else if (contactType == 'Developer') {
                System.debug('Trainee');
                if (statusValue == 'Pending') {
                    System.debug('statusValue==>'+statusValue);
                    List<Timesheet_Detail__c> tsd = [SELECT Id,Name, Task_Name__c, Task_Description__c, Date__c,Requirement__c,Requirement__r.Name,Project__c,Project__r.Name,Project__r.Project_Name__c, Start_Time__c, End_Time__c,hours__c, Comments__c,TicketNumber__c, Timesheet__c, Status__c,Timesheet__r.Daily_Status__c,Timesheet__r.Contact__r.Name FROM Timesheet_Detail__c WHERE Date__C =: date.valueOf(seldate) AND Timesheet__r.Contact__c =: recordid ORDER BY Start_Time__c ASC];
                    System.debug('tsd==>'+tsd);
                    return tsd;
                }
                else {
                    List<Timesheet_Detail__c> tsd = [SELECT Id,Name, Task_Name__c, Task_Description__c, Date__c,Requirement__c,Requirement__r.Name,Project__c, TicketNumber__c,Project__r.Name,Project__r.Project_Name__c, Start_Time__c,hours__c, End_Time__c, Comments__c, Timesheet__c, Status__c,Timesheet__r.Daily_Status__c,Timesheet__r.Contact__r.Name FROM Timesheet_Detail__c WHERE Date__C =: date.valueOf(seldate) AND Timesheet__r.Contact__c =: recordid ORDER BY Start_Time__c ASC];
                    return tsd;
                }
            }else{
                System.debug('else');
                return null;
            }
        } catch (Exception e) {
            System.debug('Error Message =>'+e.getMessage());
            return null;
        }
    }
    @AuraEnabled
    public static String updateStatus(String action, String tdId, String rejectedreason ){

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
    public static String submittimesheet(String userId, date selecteddate){
        try{
            Id conId = [SELECT Id,ContactId FROM User where Id=:userId].contactId;
            System.debug('con>>'+conId);
            Timesheet__c timesheet = [SELECT Id,Team__c,Contact__c,Date__c,Team__r.Lead_Name__c,Contact__r.Name,Team__r.Lead_Email__c, Daily_Status__c FROM Timesheet__c WHERE Contact__c=:conId AND Date__c =: selecteddate ];
            timesheet.Daily_Status__c = true;
            update timesheet;
            System.debug('timesheet>>>'+timesheet);

            List<Timesheet_Detail__c> tdlst = [SELECT Id,Timesheet__c , Project__c, Status__c FROM Timesheet_Detail__c WHERE Timesheet__c=:timesheet.Id];
            List<Timesheet_Detail__c> tdlstnew = new List<Timesheet_Detail__c>();
            for(Timesheet_Detail__c td : tdlst){
                if (td.Status__c == null) {
                    td.Status__c = 'Pending for approval';      
                }
                tdlstnew.add(td);
            }        
            update tdlstnew;

            Timesheet__c ts = [SELECT Id,isSubmitted__c FROM Timesheet__c WHERE Id=:timesheet.Id];
            ts.isSubmitted__c = true;
            update ts;

            Set<String> projectSet = new Set<String>();
            for(Timesheet_Detail__c td : tdlstnew){
                projectSet.add(td.Project__c);
            }
            List<Project__c> projectIds = [SELECT Id,Project_Lead__c,Project_Lead__r.Name,Project_Lead__r.Phone , Project_Lead__r.Email  FROM Project__c WHERE ID IN  :projectSet  ];
            System.debug('projectIds>>>'+projectIds + 'ProjectLeadRname >>'+projectIds[0].Project_Lead__r.Name);

            Set<String> contactSet = new Set<String>();
            for(Project__c p : projectIds){
                contactSet.add(p.Project_Lead__c);
            }
            System.debug('contactSet>>>'+contactSet);

            List<Contact> contactList = [SELECT Id,Name,Email,MobilePhone, Slack_Id__c FROM Contact WHERE Id IN: contactSet ];
            
            for ( Contact c : contactList) {
                System.debug('contactList>>>'+c);
                String subjectMail = 'Timesheet Submitted';

                String message = 'Hi ' + c.Name + ', \n\n';
                message += 'Greetings for the day! \n';
                message += 'Just to notify you that '+ '*' +timesheet.Contact__r.Name+'*'+' has Submitted the timesheet of '+ '*' + timesheet.Date__c.day()+'/'+timesheet.Date__c.month()+'/'+timesheet.Date__c.year()+'*'+'. ';
                message += 'Please check! ';
                // WhatsappIntegration.sendMessage(c.MobilePhone,c.name,message);
                if (String.isNotBlank(c.Slack_Id__c)) {
                    SlackIntegration.sendSlackMessage(message, c.Slack_Id__c);
                }
            }
            return 'success';
        }catch(Exception e){
            System.debug('Exception>>>'+e);
            return e.getMessage();
        }
    }  

    @AuraEnabled
    public static String deleteTimesheetRecord(String timesheetdetailId){
        try{
            Timesheet_Detail__c timesheet = [SELECT Id,Date__c FROM Timesheet_Detail__c WHERE Id=:timesheetdetailId ];
            delete timesheet;
            return 'Success';
        }catch(Exception e){
            System.debug('Exception>>>'+e);
            return e.getMessage();
        }
    }
    
    @AuraEnabled
    public static Date getOrgDate(){
        return Date.today();
    }
    
    @AuraEnabled
    public static String SaveTimeSheet(String inputFields , String userid , String recordId ){
        id timesheetid ;        
        try {   

            Date yesterday = Date.today().addDays(-1);
            TimeSheet_Detail__c timesheetdetail = (TimeSheet_Detail__c)JSON.deserialize(inputFields, TimeSheet_Detail__c.class);
            if (recordId != null && recordId != '') {
                List<Timesheet_Detail__c> td = [SELECT Id , Date__c , Start_Time__c,Timesheet__c FROM Timesheet_Detail__c WHERE Id =: recordId];
                if(timesheetdetail.Start_Time__c != td[0].Start_Time__c){
                    List<Timesheet_Detail__c> tdE = [SELECT Id , Date__c , Start_Time__c FROM Timesheet_Detail__c WHERE Start_Time__c=:timesheetdetail.Start_Time__c AND Timesheet__c =: td[0].Timesheet__c AND Date__c=:timesheetdetail.Date__c LIMIT 1];
                    if(tdE.size() > 0){
                        return 'Start Time already exists';
                    }
                        else if(td[0].Date__c != timesheetdetail.Date__c){
                        return 'Date cannot be changed';
                    } 
                    else{
                        timesheetdetail.Id = recordId;
                        update timesheetdetail;
                        return 'Timesheet Updated Successfully';                    
                    }
                }
                else if(td[0].Date__c != timesheetdetail.Date__c){
                    return 'Date cannot be changed';
                }
                else{
                    System.debug(recordId);
                    timesheetdetail.Id = recordId;
                    update timesheetdetail;
                    return 'Timesheet Updated Successfully';                    
                }
            }
            else {
                id getContactId = [select id, contactId from User where id = : userid].contactId;
                Id getTeam = [SELECT Id, Name, Team__c FROM Contact WHERE Id =: getContactId].Team__c;
                if (timesheetdetail.TicketNumber__c != null && timesheetdetail.TicketNumber__c != '') {
                    List<Requirement__c> req = [SELECT Id, Name  FROM Requirement__c WHERE Project__c =: timesheetdetail.Project__c AND Name LIKE : timesheetdetail.TicketNumber__c  ];
                    System.debug('req' + req);
                    if (req.size() > 0) {
                        timesheetdetail.Requirement__c = req[0].Id;
                    }
                    else {
                        Requirement__c newReq = new Requirement__c();
                        newReq.Name = timesheetdetail.TicketNumber__c;
                        newReq.Project__c = timesheetdetail.Project__c;
                        newReq.Status__c = 'Open';
                        insert newReq;
                        timesheetdetail.Requirement__c = newReq.Id;
                    }                    
                }
                List<Timesheet_Detail__c> td = [SELECT Id , date__c , Start_Time__c FROM Timesheet_Detail__c WHERE Start_Time__c=:timesheetdetail.Start_time__c AND Timesheet__c=:timesheetid AND Date__c=:timesheetdetail.date__c LIMIT 1];
                if(td.size()==0 && (timesheetdetail.date__c == Date.today() || timesheetdetail.date__c == yesterday)){ 
                    List<Timesheet__c> tslist = [SELECT Id, Name, Date__c FROM Timesheet__c WHERE Date__c =: timesheetdetail.date__c and Contact__C =: getContactId];
                    if (tslist.size() == 0) {
                        Timesheet__c ts = new Timesheet__c();
                        ts.Date__c = timesheetdetail.date__c;
                        ts.Team__c = getTeam;
                        ts.Contact__c = getContactId;
                        insert ts;
                        timesheetid = ts.Id;
                    }else{
                        timesheetid = tslist[0].Id;
                    }
                    timesheetdetail.TimeSheet__c = timesheetid;
                    insert timesheetdetail;
                    return 'Timesheet Created Successfully';
                }
                else if( td.size()==0 && timesheetdetail.date__c > Date.today() || timesheetdetail.date__C < yesterday ) {
                    return 'Please Select Correct Date';
                }
                else{
                    return 'Please Select Different Start Time';
                }
            }
        } catch (Exception e) {
            System.debug(' Message + Line Number--->'+e.getMessage() + e.getLineNumber());      
            return e.getMessage();
        }
    }
    @AuraEnabled
    public static List<Contact> getTrainneList (string project , Date currentDate){
        List<TimeSheet_Detail__c> userId = new List<TimeSheet_Detail__c>();
        if (project == 'All') {
            id contactId = [select id, contactId from User where id = : UserInfo.getUserId()].contactId;
            System.debug('contactId>>>'+contactId);
            List<Project__c> projectlist = [SELECT Id, Name, Project_Type__c FROM project__c WHERE Project_Lead__c = :contactId];
            userId = [SELECT CreatedById FROM TimeSheet_Detail__c WHERE Project__c IN: projectlist AND Date__c =: currentDate];
        }
        else {
            userId = [SELECT CreatedById FROM TimeSheet_Detail__c WHERE Project__c =: project AND Date__c =: currentDate];
        }
        Set<Id> userIdList = new Set<Id>();
        for(TimeSheet_Detail__c tsd : userId){
            userIdList.add(tsd.CreatedById);
        }
        System.debug('userIdList>>>'+userIdList);        
        List<User> userlist = [SELECT Id, Name, contactId FROM User WHERE Id IN : userIdList ];
        Set<Id> contactIdList = new Set<Id>();
        for (User useId : userlist) {
            contactIdList.add(useId.contactId);
        }
        List<Contact> contactlist = [SELECT Id, Name FROM Contact WHERE ContactType__c = 'Developer' AND Id IN : contactIdList ];
        System.debug('contactlist>>>'+contactlist);
        return contactlist;
    }
    @AuraEnabled
    public static String ApproveTimeSheet(String action , List<String> timesheetId){

        List<TimeSheet_Detail__c> tsdlist = [SELECT Id, Name, Start_Time__c, End_Time__c, Comments__c, Task_Name__c, Task_Description__c, Status__c, Date__c FROM TimeSheet_Detail__c WHERE Id IN : timesheetId];
        System.debug('tsdlist>>>'+tsdlist);

        for(TimeSheet_Detail__c tsd : tsdlist){
            tsd.Status__c = action;
        }
        update tsdlist;
        return 'Timesheet Approved Successfully';
    }
    @AuraEnabled
    public static string UpdateTimesheet(String recordId , String rejectReason , String comment){
        List<TimeSheet_Detail__c> tsdlist = [SELECT Id, Name, Start_Time__c, End_Time__c, Comments__c, Task_Name__c,Rejected_Reason__c ,Task_Description__c, Status__c, Date__c FROM TimeSheet_Detail__c WHERE Id =: recordId];
        if (rejectReason != null && rejectReason != '' && rejectReason != tsdlist[0].Rejected_Reason__c) {
            tsdlist[0].Rejected_Reason__c = rejectReason;
            tsdlist[0].Status__c = 'Rejected';
            update tsdlist;
            return 'Timesheet Rejected Successfully';
        }
        else if (comment!=null && comment != tsdlist[0].Comments__c && comment!='') {
            tsdlist[0].Comments__c = comment;
            update tsdlist;
            return 'Timesheet Updated Successfully';
        }
        else {
            return 'Please Enter Valid Data';
        }
    }  

    @AuraEnabled
    public static Boolean ApproveRejectDisplay(Date seldate, String statusValue) {
        Integer approvalTime = Integer.valueOf(System.Label.Time_Approve);
        Datetime dt = Datetime.newInstance(seldate.year(), seldate.month(), seldate.day());
        String weekday = dt.format('EEEE');
        String seldateMonth = String.valueOf(seldate.month());

        Date today = Date.today();
        String todateMonth = String.valueOf(today.month());

        if (weekday == 'Sunday' || weekday == 'Saturday') {
            return false;
        } else if (statusValue == 'Rejected') {
            Integer daysToAdd = 0;
            if (seldateMonth == todateMonth) {
                if (weekday == 'Friday') {
                    daysToAdd = 4;
                } else {
                    daysToAdd = approvalTime + 1;
                }
            } else {
                Date lastDayOfMonth = today.toStartOfMonth().addDays(-1);
                String lastDay = Datetime.newInstance(lastDayOfMonth.year(), lastDayOfMonth.month(), lastDayOfMonth.day()).format('EEEE');
                if (lastDay == 'Saturday') {
                    daysToAdd = 3;
                } else if (lastDay == 'Friday') {
                    daysToAdd = 4;
                } else {
                    daysToAdd = 2;
                }
            }
            Date newdate = seldate.addDays(daysToAdd);
            return (today <= newdate);
        } else {
            Integer daysToAdd = 0;
            if (seldateMonth == todateMonth) {
                if (weekday == 'Friday') {
                    daysToAdd = 3;
                } else {
                    daysToAdd = approvalTime;

                    Date newdate = seldate.addDays(daysToAdd);
                    Datetime dt1 = Datetime.newInstance(newdate.year(), newdate.month(), newdate.day());
                    String weekday1 = dt1.format('EEEE');
                    if (weekday1 == 'Saturday') {
                        daysToAdd = daysToAdd + 2;
                    } 
                    else if (weekday1 == 'Sunday') {
                        daysToAdd = daysToAdd + 1;
                    }
                }
            } else {
                Date lastDayOfMonth = today.toStartOfMonth().addDays(-1);
                String lastDay = Datetime.newInstance(lastDayOfMonth.year(), lastDayOfMonth.month(), lastDayOfMonth.day()).format('EEEE');
                if (lastDay == 'Saturday') {
                    daysToAdd = 4;
                } else if (lastDay == 'Friday') {
                    daysToAdd = 3;
                } else {
                    daysToAdd = 1;
                }
            }
            Date newdate = seldate.addDays(daysToAdd);
            return (today <= newdate);
        }
    }


    @AuraEnabled 
    public static void approveAllTimesheet(List<String> timesheetid){
        List<TimeSheet_Detail__c> tsdlist = [SELECT Id, Name, Start_Time__c, End_Time__c, Comments__c, Task_Name__c, Task_Description__c, Status__c, Date__c FROM TimeSheet_Detail__c WHERE Id IN : timesheetid AND (Status__c = '' OR Status__c = 'Pending for Approval')];
        System.debug('tsdlist>>>'+tsdlist);
        for(TimeSheet_Detail__c tsd : tsdlist){
            tsd.Status__c = 'Approved';
        }
        update tsdlist;
    }
    @AuraEnabled
    public static String getProjectType(String projectid){
        try {
            String ProjectType = [SELECT Id, Name, Project_Type__c FROM project__c WHERE Id =: projectid].Project_Type__c; 
            System.debug('ProjectType>>>'+ProjectType);
            return ProjectType;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Project__c> getAllProjects(){
        List<Project__c> projectlist = [SELECT Id, Name FROM project__c WHERE isActive__c = TRUE ORDER BY Name ASC];
        System.debug('projectlist>>>'+projectlist);
        return projectlist;
    }

    @AuraEnabled
    public static List<Requirement__c> getRequirements(String projectid){
        List<Requirement__c> requirementlist = [SELECT Id, Name, Status__c  FROM Requirement__c WHERE Status__c = 'Open' AND Project__c =: projectid ];
        System.debug('requirementlist>>>'+requirementlist);
        return requirementlist;
    }
    @AuraEnabled
    public static List<Project__c> getProjectList(String userid){
        id contactId = [select id, contactId from User where id = : userid].contactId;
        System.debug('contactId>>>'+contactId);
        List<Project__c> projectlist = [SELECT Id, Name, Project_Type__c FROM project__c WHERE Project_Lead__c = :contactId];
        System.debug('projectlist>>>'+projectlist);
        return projectlist;
    }
    @AuraEnabled
    public static Boolean ShowSubmitCreateBut(Date seldate){
        try {
            
            Date yesterday = Date.today().addDays(-1);
            Date selectedDate = (Date)seldate;
            DateTime selectedDateTime = selectedDate;
            DateTime today = Datetime.now().date();
            String todayWeekday = today.format('EEEE');
            String selectedMonth = selectedDateTime.format('MM');
            String currentMonth = today.format('MM');

            id contactId = [select id, contactId from User where id = : UserInfo.getUserId()].contactId;
            List<timesheet__c> timesheetList = [select id from timesheet__c where contact__c = : contactId And Date__c = : seldate AND isSubmitted__c = true LIMIT 1]; 

            id timesheetId = timesheetList.size() > 0 ? timesheetList[0].id : null;

            if (timesheetId != null || timesheetId != '' ) {
                List<TimeSheet_Detail__c> TimeSheetDetail = [Select ID , Name , Status__c from timesheet_detail__C where status__c !='' and Date__c =: seldate and timesheet__c =: timesheetId ];
                if (TimeSheetDetail.size()>0) {
                    return false;
                }
            }

            if (selectedMonth != currentMonth) {
                return selectedDate == Date.today();
            } else {
                boolean isTodayOrYesterday = selectedDate == Date.today() || selectedDate == yesterday;
                if (todayWeekday == 'Sunday') {
                    return isTodayOrYesterday;
                } else if (todayWeekday == 'Monday') {
                    return selectedDate == Date.today();
                } else {
                    return isTodayOrYesterday;
                }
            }     
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Timesheet_Detail__c> getRecordData(string recordId){

        List<Timesheet_Detail__c> tsd = [SELECT Id,Name, Task_Name__c, Task_Description__c, Requirement__c,Requirement__r.Name, Date__c,Project__c,Project__r.Name,Start_Time__c, End_Time__c,hours__c, Comments__c,TicketNumber__c, Timesheet__c, Status__c , Rejected_Reason__c FROM Timesheet_Detail__c WHERE Id =: recordId];
        System.debug('tsd>>>'+tsd);
        return tsd;
    }

    @AuraEnabled
    public static Boolean EditDeleteDisplay(Date seldate){

        Date newdate = seldate.addDays(4);
        if(Date.today() <= newdate){
            return true;
        }
        else{
            return false;
        }
    }

    @InvocableMethod(label='Schedual Whatsapp Msg')
    public static void SubmitTimesheetReminder(){
        try{

            Date d = System.today();
            Datetime dt = (DateTime)d;
            String dayOfWeek = dt.format('EEEE');
            if (!(dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday')) {
                Date TodayDate = Date.today();
                Map<Id, String> uniqueConToday = new Map<Id, String>();

                List<user> ConLIst = [SELECT Id, name, Profile.Name, ProfileId, Contact.Name,Contact.Id,Contact.MobilePhone FROM user WHERE Profile.Name = 'mtp community user']; 
                for(user con : ConLIst){
                    uniqueConToday.put(con.Contact.id ,con.Contact.MobilePhone);
                }
                List<Timesheet__c> ContactList = [SELECT Id,Contact__c,Contact__r.Name,Contact__r.MobilePhone,Daily_Status__c FROM Timesheet__c WHERE Date__c = TODAY];
                for(Timesheet__c t : ContactList){
                    uniqueConToday.remove(t.Contact__c);
                }
                System.Debug('uniqueConLast : '+uniqueConToday);

                // String message = 'We hope you are doing well...!!   This message is just to remind you to Submit your Timesheet for today as soon as you can.';

                for(Contact c : [SELECT Id,Name,MobilePhone, Description, Slack_Id__c FROM Contact WHERE Id IN :uniqueConToday.keyset()]){
                    String message = 'Hi ' + c.Name + ', \n\n';
                    message += 'We hope you are doing well...!!   This message is just to remind you to Submit your Timesheet for today as soon as you can.';
                    // WhatsappIntegration.sendMessage(c.MobilePhone,c.Name ,message);
                    if (c.Description == 'Trainee' && String.isNotBlank(c.Slack_Id__c)) {
                        SlackIntegration.sendSlackMessagetrainee(message, c.Slack_Id__c);
                    }
                    else if (String.isNotBlank(c.Slack_Id__c)) {
                        SlackIntegration.sendSlackMessage(message, c.Slack_Id__c);
                    }
                }
            }
        }
        catch (Exception e) {
            System.debug('Error in Method => '+ e.getMessage());
        }
    }
    
    public static void WeeklyTimeSheetReport(){

        List<user> ConLIst = [SELECT Id, name, Profile.Name, ProfileId, Contact.Name,Contact.Id,Contact.MobilePhone FROM user WHERE Profile.Name = 'mtp community user'];

        List<Timesheet_Detail__c> TimeSheetNotSubmited = [SELECT Date__c , Timesheet__r.Contact__c, Timesheet__r.Contact__r.Name, Timesheet__r.Contact__r.MobilePhone FROM Timesheet_Detail__c WHERE CreatedById IN (SELECT Id FROM user WHERE Profile.Name = 'mtp community user') AND Date__c >= LAST_WEEK AND Date__c < THIS_WEEK AND Status__c = ''];

        Map<Date,Set<Id>> contactsWithoutSubmission = new Map<Date,Set<Id>>();
        for(Timesheet_Detail__c ts : TimeSheetNotSubmited){
            if(contactsWithoutSubmission.containsKey(ts.Date__c)){
                contactsWithoutSubmission.get(ts.Date__c).add(ts.Timesheet__r.Contact__r.Name);
            }
            else{
                Set<Id> contactIds = new Set<Id>();
                contactIds.add(ts.Timesheet__r.Contact__c);
                contactsWithoutSubmission.put(ts.Date__c,contactIds);
            }
        }

        System.debug( 'contactsWithoutSubmission : '+contactsWithoutSubmission);

        List<Timesheet_Detail__c> timesheets = [SELECT Id, Name , date__c, Status__c,
                                                    CreatedById,CreatedDate,Timesheet__c, Timesheet__r.Contact__c,
                                                    Timesheet__r.Contact__r.Name, Timesheet__r.Contact__r.MobilePhone
                                                FROM Timesheet_Detail__c
                                                WHERE CreatedById IN (SELECT Id FROM user WHERE Profile.Name = 'mtp community user')
                                                AND Date__c >= LAST_WEEK
                                                AND Date__c < THIS_WEEK
        ];

        Map<Date,String> contactsWithoutTimesheet = new Map<Date,String>();  
        List<Date> dates = new List<Date>();

        Date LastWeekDate = Date.today().addDays(-7);
        for (Integer i = 0; i < 5; i++) {
            dates.add(LastWeekDate.addDays(i));
        }
        for (Date d : dates) {
            for (user con : ConLIst) {
                Boolean found = false;
                for (Timesheet_Detail__c ts : timesheets) {
                    if (ts.Timesheet__r.Contact__c == con.Contact.Id && ts.Date__c == d) {
                        found = true;
                        break;
                    }
                }
                if (!found) {
                    if (contactsWithoutTimesheet.containsKey(d)) {
                        contactsWithoutTimesheet.put(d, contactsWithoutTimesheet.get(d));
                        System.debug('contactsWithoutTimesheet.get(d) : '+contactsWithoutTimesheet);
                    } else {
                        contactsWithoutTimesheet.put(d, con.Contact.Name);
                    }
                }
            }
        }
    }

    @AuraEnabled
    public static String MentorSubmitTimeSheet(String userId, date selecteddate){
        try {
            
            Id conId = [SELECT Id,ContactId FROM User where Id=:userId].contactId;
            System.debug('con>>'+conId);
            Timesheet__c timesheet = [SELECT Id,Team__c,Contact__c,Date__c,Team__r.Lead_Name__c,Contact__r.Name,Team__r.Lead_Email__c, Daily_Status__c FROM Timesheet__c WHERE Contact__c=:conId AND Date__c =: selecteddate ];
            timesheet.Daily_Status__c = true;
            update timesheet;

            List<Timesheet_Detail__c> tdlst = [SELECT Id,Timesheet__c , Project__c, Status__c FROM Timesheet_Detail__c WHERE Timesheet__c=:timesheet.Id];
            List<Timesheet_Detail__c> tdlstnew = new List<Timesheet_Detail__c>();
            for(Timesheet_Detail__c td : tdlst){
                if (td.Status__c == null) {
                    td.Status__c = 'Pending for approval';      
                }
                tdlstnew.add(td);
            }        
            update tdlstnew;
            return 'success';
        } catch (Exception e) {
            System.debug('Error in Method => '+ e.getMessage());
            return e.getMessage() +'--- '+ e.getLineNumber() +'---' + userId +'---' + selecteddate;
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
    public static String getFieldSet(String objectName, String fieldSetName){
        System.debug('objectName>>>'+objectName);
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
                    jsonPart += '"required": '+ (f.getDBRequired() || f.getRequired())+',';
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
}















































































































    
    

    // @AuraEnabled
    // public static Decimal returnTimeSlotValue(){
    //     try {
    //         Decimal TimeSlot;
    //         list<Timeslot__c> timelist = [SELECT time_slot_time__c FROM Timeslot__c];
    //         TimeSlot = timelist[0].time_slot_time__c;
    //         system.debug(TimeSlot);
    //         return TimeSlot;
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());   
    //     }
    // }


// public static void WeeklyTimeSheetMail(){
    //     List<user> ConLIst = [SELECT Id, name, Profile.Name, ProfileId, Contact.Name,Contact.Id,Contact.MobilePhone FROM user WHERE Profile.Name = 'mtp community user'];
    
    //     List<Timesheet_Detail__c> timesheets = [SELECT Id, Name , date__c, Status__c,
    //                                                 CreatedById,CreatedDate,Timesheet__c, Timesheet__r.Contact__c,
    //                                                 Timesheet__r.Contact__r.Name, Timesheet__r.Contact__r.MobilePhone
    //                                             FROM Timesheet_Detail__c
    //                                             WHERE CreatedById IN (SELECT Id FROM user WHERE Profile.Name = 'mtp community user')
    //                                             AND Date__c >= LAST_WEEK
    //                                             AND Date__c < THIS_WEEK
    //     ];
    //     Map<Date,String> contactsWithoutTimesheet = new Map<Date,String>();  
    //     List<Date> dates = new List<Date>();
    //     Date LastWeekDate = Date.today().addDays(-7);
    //     for (Integer i = 0; i < 5; i++) {
    //         dates.add(LastWeekDate.addDays(i));
    //     }
    //     for (Date d : dates) {
    //         for (user con : ConLIst) {
    //             Boolean found = false;
    //             for (Timesheet_Detail__c ts : timesheets) {
    //                 if (ts.Timesheet__r.Contact__c == con.Contact.Id && ts.Date__c == d) {
    //                     found = true;
    //                     break;
    //                 }
    //             }
    //             if (!found) {
    //                 if (contactsWithoutTimesheet.containsKey(d)) {
    //                     contactsWithoutTimesheet.put(d, contactsWithoutTimesheet.get(d));
    //                     System.debug('contactsWithoutTimesheet.get(d) : '+contactsWithoutTimesheet);
    //                 } else {
    //                     contactsWithoutTimesheet.put(d, con.Contact.Name);
    //                 }
    //             }
    //         }
    //     }
    // }
    // public static void NotSubmiteTimesheetMail(){
    //     try{
    //         Map<Id, String> uniqueConToday = new Map<Id, String>();
    //         Map<Id, String> uniqueConYesterday = new Map<Id, String>();

    //         List<user> ConLIst = [SELECT Id, name, Profile.Name, ProfileId, Contact.MobilePhone,Contact.Id,Contact.Name FROM user WHERE Profile.Name = 'mtp community user' or Profile.Name = 'Trainee Portal Login'];
    //             for(user con : ConLIst){
    //                 uniqueConToday.put(con.Contact.id ,con.Contact.Name);
    //                 uniqueConYesterday.put(con.Contact.id ,con.Contact.Name);
                    
    //             }       
    //         List<Timesheet__c> ContactList = [SELECT Id,Contact__c,Contact__r.Name,Contact__r.MobilePhone,Daily_Status__c FROM Timesheet__c WHERE Daily_Status__c = true AND Date__c = TODAY];
    //             for(Timesheet__c t : ContactList){
    //                 uniqueConToday.remove(t.Contact__c);
    //             }
    //         System.Debug('Not Submitted or filled : '+uniqueConToday);

    //         list<String> FinalConToday = new list<String>();
    //             for(Contact c : [SELECT Id,Name,MobilePhone FROM Contact WHERE Id IN :uniqueConToday.keyset()]){
    //                 FinalConToday.add(c.Name);
    //             }
    //         System.debug('Timesheet Not Filled Or Submitted today : '+ FinalConToday);
                    
    //         List<Timesheet__c> ContactList2 = [SELECT Id,Contact__c,Contact__r.Name,Contact__r.MobilePhone,Daily_Status__c FROM Timesheet__c WHERE Daily_Status__c = true AND Date__c = YESTERDAY];
    //             for(Timesheet__c t : ContactList2){
    //                 uniqueConYesterday.remove(t.Contact__c);
    //                 System.debug('SubmittedYesterDay: '+ t.Contact__r.MobilePhone+'  Contact Name: '+ t.Contact__r.Name);
    //             }
    //             System.Debug('Not Submitted or filled : '+uniqueConYesterday);
    //         list<String> FinalConYesterday = new list<String>();
    //             for(Contact c : [SELECT Id,Name,MobilePhone FROM Contact WHERE Id IN :uniqueConYesterday.keyset()]){
    //                 FinalConYesterday.add(c.Name);
    //             }
    //         System.debug('Timesheet Not Filled Or Submitted Yesterday : '+ FinalConYesterday);

    //         String EmailId = 'nirnavik@gmail.com';
    //         String GmailBody = 'Hello Dharmik Shah,<br></br>';
    //         GmailBody += 'This Email Is Providing Informantion About Employees How Did Not Fill Or Submit Tiemsheet</br>';
    //         GmailBody += 'Traine How Did Not Submitted Timesheet Yesterday : </br>';
    //         GmailBody += FinalConYesterday + '</br>';
    //         GmailBody += 'Traine How Did Not Submitted Timesheet Today : </br>';
    //         GmailBody += FinalConToday + '</br>';
    //         GmailBody += '- Mv Clouds';
    //         sendGmail('Leave Staus Update', GmailBody, EmailId);
    //     }
    //     catch(Exception e){
    //         System.debug('Error in Method => '+ e.getMessage() +' '+e.getLineNumber());
    //     }
    // }

     // @AuraEnabled
    // public static Boolean ApproveRejectDisplay(Date seldate ,  String statusValue){ // Nirbhay
    //     String ApprovalTime = System.Label.Time_Approve;
    //     Integer ApprovalTimeInt = Integer.valueOf(ApprovalTime);        
    //     Datetime dt = (DateTime)seldate;
    //     String weekday = dt.format('EEEE');

    //     String seldateMonth = dt.format('MM');

    //     Datetime todate = (Datetime)Date.today();
    //     String todateMonth = todate.format('MM');

    //     // if selected date is sunday then retrun false
    //     if(weekday == 'Sunday'){
    //         return false;
    //     }
    //     else if(weekday == 'Saturday'){
    //         return false;
    //     }
    //     else if(statusValue =='Rejected'){
    //         if(seldateMonth == todateMonth){
    //             if(weekday == 'Sunday'){
    //                 Date newdate = seldate.addDays(2);
    //                 if(Date.today() <= newdate){
    //                     return true;
    //                 }
    //                 else{
    //                     return false;
    //                 }
    //             }
    //             else if(weekday == 'Saturday'){
    //                 Date newdate = seldate.addDays(3);
    //                 if(Date.today() <= newdate){
    //                     return true;
    //                 }
    //                 else{
    //                     return false;
    //                 }
    //             }
    //             else if(weekday == 'Friday'){
    //                 Date newdate = seldate.addDays(4);
    //                 if(Date.today() <= newdate){
    //                     return true;
    //                 }
    //                 else{
    //                     return false;
    //                 }
    //             }
    //             else{
    //                 Date newdate = seldate.addDays(ApprovalTimeInt + 1);
    //                 if(Date.today() <= newdate){
    //                     return true;
    //                 }
    //                 else{
    //                     return false;
    //                 }
    //             }
    //         } 
    //         else if (seldateMonth != todateMonth){

    //                 Date lastDayOfMonth = Date.today().toStartOfMonth().addDays(-1);
    //                 system.debug(lastDayOfMonth);
    //                 Datetime lDoF = (Datetime)lastDayOfMonth;
    //         		String lastDay = lDoF.format('EEEE');

    //                 if(lastDay == 'Saturday'){
    //                     Date newdate = lastDayOfMonth.addDays(3);
    //                     if(Date.today() <= newdate){
    //                         return true;
    //                     }
    //                     else{
    //                         return false;
    //                     } 
    //                 }

    //                 else if(lastDay == 'Friday'){
    //                     Date newdate = lastDayOfMonth.addDays(4);
    //                     if(Date.today() <= newdate){
    //                         return true;
    //                     }
    //                     else{
    //                         return false;
    //                     } 
    //                 }
    //                  else {
    //                         Date newdate = lastDayOfMonth.addDays(2);
    //                         if(Date.today() <= newdate){
    //                             return true;
    //                         }
    //                         else{
    //                             return false;
    //                         }  
    //                  }  
    //         } 
    //         return null;
    //     }
    //     else{
    //         if(seldateMonth == todateMonth){
    //             if(weekday == 'Sunday'){
    //                 Date newdate = seldate.addDays(1);
    //                 if(Date.today() <= newdate){
    //                     return true;
    //                 }
    //                 else{
    //                     return false;
    //                 }
                    

    //             }
    //             else if(weekday == 'Saturday'){
    //                 Date newdate = seldate.addDays(2);
    //                 if(Date.today() <= newdate){
    //                     return true;
    //                 }
    //                 else{
    //                     return false;
    //                 }
    
    //             }
    //             else if(weekday == 'Friday'){
    //                 Date newdate = seldate.addDays(3);
    //                 if(Date.today() <= newdate){
    //                     return true;
    //                 }
    //                 else{
    //                     return false;
    //                 }
    //             }
    //             else{
    //                 Date newdate = seldate.addDays(ApprovalTimeInt);
    //                 if(Date.today() <= newdate){
    //                     return true;
    //                 }
    //                 else{
    //                     return false;
    //                 }
    //             }
    //         } 

    //         else if (seldateMonth != todateMonth){

    //                 Date lastDayOfMonth = Date.today().toStartOfMonth().addDays(-1);
    //                 system.debug(lastDayOfMonth);
    //                 Datetime lDoF = (Datetime)lastDayOfMonth;
    //         		String lastDay = lDoF.format('EEEE');

    //                 if(lastDay == 'Saturday'){
    //                     Date newdate = lastDayOfMonth.addDays(4);
    //                     if(Date.today() <= newdate){
    //                         return true;
    //                     }
    //                     else{
    //                         return false;
    //                     } 
    //                 }

    //                 else if(lastDay == 'Friday'){
    //                     Date newdate = lastDayOfMonth.addDays(3);
    //                     if(Date.today() <= newdate){
    //                         return true;
    //                     }
    //                     else{
    //                         return false;
    //                     } 
    //                 }
    //                  else {
    //                         Date newdate = lastDayOfMonth.addDays(1);
    //                         if(Date.today() <= newdate){
    //                             return true;
    //                         }
    //                         else{
    //                             return false;
    //                         }  
    //                  }

                    
                
    //         } 
    //         return null;
    //     }

        // if(statusValue =='Rejected'){
        //     if(weekday == 'Friday'){
        //         Date newdate = seldate.addDays(ApprovalTimeInt + 3);
        //         System.debug('newdate>>>'+newdate);
        //         if(Date.today() <= newdate){
        //             return true;
        //         }
        //         else{
        //             return false;
        //         }
        //     }
        //     else if(weekday == 'Saturday'){
        //         Date newdate = seldate.addDays(ApprovalTimeInt + 2);
        //         if(Date.today() <= newdate){
        //             return true;
        //         }
        //         else{
        //             return false;
        //         }
        //     }
        //     else {
        //         Date newdate = seldate.addDays(ApprovalTimeInt + 1);
        //         if(Date.today() <= newdate){
        //             return true;
        //         }
        //         else{
        //             return false;
        //         }
        //     }
        // }else{
        //     if(weekday == 'Friday'){
        //         Date newdate = seldate.addDays(ApprovalTimeInt + 2);
        //         System.debug('newdate>>>'+newdate);
        //         if(Date.today() <= newdate){
        //             return true;
        //         }
        //         else{
        //             return false;
        //         }
        //     }
        //     else if(weekday == 'Saturday'){
        //         Date newdate = seldate.addDays(ApprovalTimeInt + 1);
        //         if(Date.today() <= newdate){
        //             return true;
        //         }
        //         else{
        //             return false;
        //         }
        //     }
        //     else {
        //         Date newdate = seldate.addDays(ApprovalTimeInt);
        //         if(Date.today() <= newdate){
        //             return true;
        //         }
        //         else{
        //             return false;
        //         }
        //     }
        // }
    // }