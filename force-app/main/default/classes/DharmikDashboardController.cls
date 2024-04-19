public class DharmikDashboardController {

    @AuraEnabled(cacheable=true)
    public static List<userwrap> getuserdata() {
        List<userwrap> uswraplst = new List<userwrap>();
        for(Contact con : [SELECT Id, Name, Email, ContactType__c FROM Contact WHERE ContactType__c != '' ORDER BY Name ASC]) {
            userwrap wrap = new userwrap();
            wrap.Id = con.Id;
            wrap.username = con.Name;
            aggregateresult[] aggregateres = [SELECT SUM(Total_Hour__c)Q FROM Timesheet__c WHERE Contact__c =: con.Id];
            Object totalsum = aggregateres[0].get('Q');
            wrap.totalhours = String.valueOf(totalsum);
            wrap.type = con.ContactType__c;
            uswraplst.add(wrap);
        }
        return uswraplst;
    }

    public class userwrap{
        @AuraEnabled
        public String Id{get;set;}
        @AuraEnabled
        public String username{get;set;}
        @AuraEnabled
        public String type{get;set;}
        @AuraEnabled
        public String totalhours{get;set;}
    }

    @AuraEnabled
    public static List<TimeSheet_detail__c> getTimeSheetData( String selectedUserId , String StatusValue , String TimeInterval){
        String whereClause = '';
        String querystr = '';
        try {

            if (StatusValue  != '' && StatusValue != null && TimeInterval != '' && TimeInterval != null && selectedUserId !='' && selectedUserId != null) {
                whereClause = 'WHERE Status__c =: \''+ StatusValue+'\''+' AND TimeSheet__r.Contact__c =: \''+ selectedUserId+'\''+ 'AND Date__c >= LAST_WEEK AND Date__c < \''+ TimeInterval+'\'';
            }
            else {
                whereClause = 'WHERE TimeSheet__r.Contact__c =: \''+ selectedUserId+'\''+' AND Date__c >= LAST_WEEK AND Date__c < THIS_WEEK ';
            }
            
            // List<TimeSheet_detail__c> timesheetlst = [SELECT Id, Name, TimeSheet__r.Contact__c,Hours__c, TimeSheet__r.Contact__r.Name, TimeSheet__r.Contact__r.ContactType__c,Status__c, Project__c, Project__r.Name,Task_Description__c, Project__r.Project_Type__c, Date__c , TicketNumber__c FROM  TimeSheet_detail__c WHERE TimeSheet__r.Contact__c =: selectedUserId AND Date__c >= LAST_WEEK AND Date__c < THIS_WEEK ORDER BY Name ASC ];

            querystr = 'SELECT Id, Name, TimeSheet__r.Contact__c,Hours__c, TimeSheet__r.Contact__r.Name, TimeSheet__r.Contact__r.ContactType__c,Status__c, Project__c, Project__r.Name,Task_Description__c, Project__r.Project_Type__c, Date__c , TicketNumber__c FROM  TimeSheet_detail__c '+ whereClause +' ORDER BY Name ASC';
            return Database.query(querystr);

            // return timesheetlst;

        } catch (Exception e) {
            throw new AuraHandledException(querystr + '  ' + e.getMessage());
        }
    }

}

// "SELECT Id, Name, TimeSheet__r.Contact__c,Hours__c, TimeSheet__r.Contact__r.Name, TimeSheet__r.Contact__r.ContactType__c,Status__c, Project__c, Project__r.Name,Task_Description__c, Project__r.Project_Type__c, Date__c , TicketNumber__c FROM  TimeSheet_detail__c WHERE TimeSheet__r.Contact__c =: '0036D00000iCZxpQAG' AND Date__c >= LAST_WEEK AND Date__c < THIS_WEEK  ORDER BY Name ASC WHERE TimeSheet__r.Contact__c =: '0036D00000iCZxpQAG' AND Date__c >= LAST_WEEK AND Date__c < THIS_WEEK  Only variable references are allowed in dynamic SOQL/SOSL."