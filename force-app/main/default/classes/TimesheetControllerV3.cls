public without sharing class TimesheetControllerV3 {

    @AuraEnabled
    public static dataWrapper getRelatedData(){
        
        Contact con = [SELECT Id, Name, Description, ContactType__c FROM Contact WHERE Id IN (SELECT contactId FROM User WHERE Id =: UserInfo.getUserId())];

        dataWrapper dataWrap = new dataWrapper();
        dataWrap.todayDate = Date.today();
        dataWrap.contactData = con;

        if (con.ContactType__c == 'Trainee') {
            List<String> nameList = new List<String>{'Salesforce Trainee', 'Miscellaneous'};
            List<Project__c> projectlist = [SELECT Id, Name FROM project__c WHERE isActive__c = TRUE AND Name IN: nameList ORDER BY Name ASC];
            dataWrap.allProjects = projectlist;
            dataWrap.selectedProjects = projectlist;
        } else {
            List<Project__c> allProjectlist = [SELECT Id, Name FROM project__c WHERE isActive__c = TRUE ORDER BY Name ASC];
            if (con.Description != null) {
                List<String> projectNames = (List<String>) JSON.deserialize(con.Description, List<String>.class);
                List<Project__c> selectedProjectlist = [SELECT Id, Name FROM project__c WHERE isActive__c = TRUE AND Name IN: projectNames ORDER BY Name ASC];
                dataWrap.allProjects = allProjectlist;
                dataWrap.selectedProjects = selectedProjectlist;
            } else {
                dataWrap.allProjects = allProjectlist;
                dataWrap.selectedProjects = allProjectlist;
            }
        }
        return dataWrap;
    }

    @AuraEnabled
    public static List<Timesheet_Detail__c> getTimesheetData(String contactId, Date selectedDate){
        List<Timesheet_Detail__c> tsd = [SELECT Id,Name, Task_Name__c, Task_Description__c, Task_Type__c, Date__c,Project__c, TicketNumber__c,Project__r.Name,Project__r.Project_Name__c, Start_Time__c,hours__c, End_Time__c, Comments__c, Timesheet__c, Status__c,Timesheet__r.isSubmitted__c FROM Timesheet_Detail__c WHERE Date__C =: date.valueOf(selectedDate) AND Timesheet__r.Contact__c =: contactId ORDER BY Start_Time__c ASC];
        return tsd;
    }

    @AuraEnabled
    public static List<Timesheet_Detail__c> submitTimesheet(String contactId, date selectedDate){
        Timesheet__c timesheet = [SELECT Id, Contact__c, Date__c, Contact__r.Name, isSubmitted__c FROM Timesheet__c WHERE Contact__c=:contactId AND Date__c =: selecteddate ];
        timesheet.isSubmitted__c = true;
        update timesheet;
        return getTimesheetData(contactId, selectedDate);
    }  

    @AuraEnabled
    public static List<Timesheet_Detail__c> unlockTimesheet(String contactId, date selectedDate){
        Timesheet__c timesheet = [SELECT Id, Contact__c, Date__c, Contact__r.Name, isSubmitted__c FROM Timesheet__c WHERE Contact__c=:contactId AND Date__c =: selecteddate ];
        timesheet.isSubmitted__c = false;
        update timesheet;
        return getTimesheetData(contactId, selectedDate);
    }  

    @AuraEnabled
    public static List<Timesheet_Detail__c> deleteTimesheetRecord(String timesheetdetailId, String contactId, date selectedDate){
        Timesheet_Detail__c timesheet = [SELECT Id, Date__c, TimeSheet__c FROM Timesheet_Detail__c WHERE Id=:timesheetdetailId ];
        delete timesheet;
        return getTimesheetData(contactId, selectedDate);
    }

    @AuraEnabled
    public static List<Timesheet_Detail__c> createTimeSheetRec(String newTSData, String contactId){   
        TimeSheet_Detail__c timeSheetDetail = (TimeSheet_Detail__c)JSON.deserialize(newTSData, TimeSheet_Detail__c.class);
        id timesheetid;
        List<Timesheet__c> tslist = [SELECT Id, Name, Date__c, isSubmitted__c FROM Timesheet__c WHERE Date__c =: timeSheetDetail.date__c AND Contact__C =: contactId];
        if (tslist.size() == 0){
            Timesheet__c ts = new Timesheet__c();
            ts.Date__c = timeSheetDetail.date__c;
            ts.Contact__c = contactId;
            insert ts;
            timesheetid = ts.Id;
        } else{
            timesheetid = tslist[0].Id;
            if (tslist[0].isSubmitted__c == true) {
                return null;
            }
        }
        timeSheetDetail.TimeSheet__c = timesheetid;
        insert timeSheetDetail;
        return getTimesheetData(contactId, timeSheetDetail.date__c);
    }

    @AuraEnabled
    public static List<Timesheet_Detail__c> updateTimeSheet(String tsRecords, String contactId, date selectedDate){   
        List<TimeSheet_Detail__c> tsDetailList = (List<TimeSheet_Detail__c>)JSON.deserialize(tsRecords, List<TimeSheet_Detail__c>.class);
        update tsDetailList;
        return getTimesheetData(contactId, selectedDate);
    }

    @AuraEnabled
    public static List<Timesheet_Detail__c> updateProjects(String projects, Contact con, date selectedDate){   
        con.Description = projects;
        update con;
        return getTimesheetData(con.Id, selectedDate);
    }

    public class dataWrapper {
        @AuraEnabled 
        public Date todayDate {get;set;}

        @AuraEnabled 
        public Contact contactData {get;set;}

        @AuraEnabled 
        public List<Project__c> allProjects {get;set;}

        @AuraEnabled 
        public List<Project__c> selectedProjects {get;set;}
    }
    
    @InvocableMethod(label='Schedual reminder message from TimesheetControllerV3')
    public static void SubmitTimesheetReminder(){
        try{
            Date d = System.today();
            Datetime dt = (DateTime)d;
            String dayOfWeek = dt.format('EEEE');
            if (!(dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday')) {
                Map<Id, String> uniqueConToday = new Map<Id, String>();

                List<user> ConLIst = [SELECT Id, name, Profile.Name, ProfileId, Contact.Name,Contact.Id,Contact.MobilePhone FROM user WHERE Profile.Name = 'mtp community user']; 
                for(user con : ConLIst){
                    uniqueConToday.put(con.Contact.id ,con.Contact.MobilePhone);
                }

                List<Timesheet__c> ContactList = [SELECT Id,Contact__c,Contact__r.Name,Contact__r.MobilePhone,Daily_Status__c FROM Timesheet__c WHERE Date__c = YESTERDAY];
                for(Timesheet__c t : ContactList){
                    uniqueConToday.remove(t.Contact__c);
                }
                System.Debug('uniqueConLast : '+uniqueConToday);

                for(Contact c : [SELECT Id,Name,MobilePhone, Description, Slack_Id__c FROM Contact WHERE Id IN :uniqueConToday.keyset()]){
                    String message = 'Hi ' + c.Name + ', \n\n';
                    message += 'We hope you are doing well...!!   This message is just to remind you to Submit your Yesterday\'s Timesheet as soon as you can.';
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
}