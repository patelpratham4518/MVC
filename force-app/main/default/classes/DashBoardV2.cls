public with sharing class DashBoardV2 {
    
    @AuraEnabled
    public static List<userwrap> getUsersList(String selectedStatus,  Integer selectedMonth , Integer selectedYear) {
        List<userwrap> uswraplst = new List<userwrap>();
        try{

        
        List<TimeSheet__c> timesheetList = new List<TimeSheet__c>();
        if (selectedStatus == 'Not Submitted') {
            timesheetList = [
                SELECT Id, Comment__c, Contact__c, Daily_Status__c, Date__c, Status_Updated_By__c,Status__c, 
                Team__c, isSubmitted__c,Total_Hour__c,Name,Contact__r.Name,Contact__r.MobilePhone
                FROM TimeSheet__c 
                WHERE isSubmitted__c = false 
                    AND CALENDAR_MONTH(Date__c) = :selectedMonth 
                    AND CALENDAR_YEAR(Date__c) = :selectedYear 
                ORDER BY Date__c ASC
            ];

            for (Timesheet__c tst : timesheetList) {
                userwrap us = new userwrap();
                // us.Id = tst.Id;
                us.ContactName = tst.Contact__r.Name;
                us.Status = tst.Status__c;
                us.Datee = tst.Date__c;
                us.totalhours = String.ValueOf(tst.Total_Hour__c);
                uswraplst.add(us);
            }
        }
        
        // if (selectedStatus == 'Not Filled') {

        //     Date startDate = Date.newInstance(selectedYear, selectedMonth, 1);
        //     Date endDate = startDate.addMonths(1);            

        //     List<user> ConLIst = [SELECT Id, name, Profile.Name, ProfileId, Contact.Name,Contact.Id,Contact.MobilePhone FROM user WHERE Profile.Name = 'mtp community user'];

        //     List<Timesheet__c> timesheetNotFilled = [SELECT Date__c , Contact__c, Contact__r.Name, Contact__r.MobilePhone FROM Timesheet__c WHERE CreatedById IN (SELECT Id FROM user WHERE Profile.Name = 'mtp community user') AND (Date__c >=: startDate AND Date__c <=: endDate)  ];

        //     Map<Date,Set<String>> contactsWithoutTimesheet = new Map<Date,Set<String>>();



        //     for(Timesheet__c ts : timesheetNotFilled){

        //         if(contactsWithoutTimesheet.containsKey(ts.Date__c)){
        //             contactsWithoutTimesheet.get(ts.Date__c).add(ts.Contact__r.Name);
        //         }
        //         else{
        //             Set<String> contactname = new Set<String>();
        //             contactname.add(ts.Contact__r.Name);
        //             contactsWithoutTimesheet.put(ts.Date__c,contactname);
        //         }
        //     }
        //     System.debug( 'contactsWithoutTimesheet : '+contactsWithoutTimesheet);
        //     for(Date d : contactsWithoutTimesheet.keySet()){
        //         for(String con : contactsWithoutTimesheet.get(d)){
        //             userwrap us = new userwrap();
        //             // us.Id = string.valueOf(i++);
        //             us.ContactName = con;
        //             us.Status = 'Not Filled';
        //             us.Datee = d;
        //             us.totalhours = '';
        //             uswraplst.add(us);
        //         }
        //     }
        //     System.debug( 'uswraplst ----> : '+uswraplst);
        // }

        if (selectedStatus == 'Not Filled') {

            Date startDate = Date.newInstance(selectedYear, selectedMonth, 1);
            Date endDate = startDate.addMonths(1);
        
            List<user> userList = [SELECT Id, name, Profile.Name, ProfileId, Contact.Name, Contact.Id, Contact.MobilePhone FROM user WHERE Profile.Name = 'mtp community user'];
                
            for(Date d = startDate; d < endDate; d = d.addDays(1)) {
        
                List<Timesheet__c> timesheetNotFilled = [SELECT Date__c, Contact__c, Contact__r.Name, Contact__r.MobilePhone FROM Timesheet__c WHERE CreatedById IN (SELECT Id FROM user WHERE Profile.Name = 'mtp community user') AND Date__c =: d];
        
                Set<String> contactsWithTimesheet = new Set<String>();
                for(Timesheet__c ts : timesheetNotFilled){
                    contactsWithTimesheet.add(ts.Contact__r.Name);
                }
        
                Set<String> contactsWithoutTimesheet = new Set<String>();
                for(user u : userList){
                    if(!contactsWithTimesheet.contains(u.Contact.Name)){
                        contactsWithoutTimesheet.add(u.Contact.Name);
                    }
                }
        
                for(String con : contactsWithoutTimesheet){
                    userwrap us = new userwrap();
                    us.ContactName = con;
                    us.Status = 'Not Filled';
                    us.Datee = d;
                    us.totalhours = '';
                    uswraplst.add(us);
                }
            }
        
            System.debug( 'uswraplst ----> : '+uswraplst);
        }
        


        if (selectedStatus == 'Not Approved') {
            timesheetList = [
                SELECT Id, Comment__c, Contact__c, Daily_Status__c, Date__c, Status_Updated_By__c,Status__c, 
                Team__c, isSubmitted__c,Total_Hour__c,Name,Contact__r.Name,Contact__r.MobilePhone
                FROM TimeSheet__c 
                WHERE isSubmitted__c = true 
                AND Contact__r.ContactType__c = 'Developer'
                AND CALENDAR_MONTH(Date__c) = :selectedMonth 
                AND CALENDAR_YEAR(Date__c) = :selectedYear 
                    AND (Status__c != 'Approved' AND status__c != 'Rejected')
                ORDER BY Date__c ASC
            ];

            for (Timesheet__c tst : timesheetList) {
                userwrap us = new userwrap();
                // us.Id = tst.Id;
                us.ContactName = tst.Contact__r.Name;
                us.Status = tst.Status__c;
                us.Datee = tst.Date__c;
                us.totalhours = String.ValueOf(tst.Total_Hour__c);
                uswraplst.add(us);
            }
        }
        } catch(Exception e) {
            System.debug('ERROR'+e.getMessage());
        }
        return uswraplst;
    }

    public class userwrap{
        @AuraEnabled
        public String ContactName{get;set;}
        @AuraEnabled
        public String Status{get;set;}
        @AuraEnabled
        public Date Datee{get;set;}
        @AuraEnabled
        public String totalhours{get;set;}
    }

}