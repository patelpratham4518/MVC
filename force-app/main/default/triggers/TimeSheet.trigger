trigger TimeSheet on Time_Sheet__c (after insert) {
    
    User oUser = [select id,Name,TimeZoneSidKey,Username,Alias,Country,Email,FirstName,LastName,IsActive,IsPortalEnabled,Title,CompanyName 
                 FROM User Where id =: userInfo.getUserId()];
    Integer Minutes;
    
    for(Time_Sheet__c timesheet : Trigger.Old){
        // if(timesheet.Employee__r.Last_Name__c == oUser.LastName){
            System.debug('Minutes'+timesheet.Minutes__c);
        //} 
    } 
}