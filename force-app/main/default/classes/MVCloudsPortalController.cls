public with sharing class MVCloudsPortalController {

    @AuraEnabled
    public static String loginAuthentication(String email , String pass){
        System.debug('Email == :'+email);
        String isAuthorized = 'failed';
        List<Employee__c> employeeDetail = [Select Id,Email__c,Password__c from Employee__c Where Email__c =: email AND Password__c =: pass LIMIT 1];
        
        if(employeeDetail.size()>0){
            isAuthorized = 'Success';
        }else{
            isAuthorized = 'failed';
        }
        
        return isAuthorized;
    }
    @AuraEnabled 
    public static user fetchUser(){
      User oUser = [select id,Name,TimeZoneSidKey,Username,Alias,Country,Email,FirstName,LastName,IsActive,IsPortalEnabled,Title,CompanyName 
                 FROM User Where id =: userInfo.getUserId()];
        return oUser;
    }
   

      @AuraEnabled
    public static Boolean checkPass(String Cpass){
        Boolean newPasswd ;
        try{
            System.setPassword(userInfo.getUserId() , Cpass);
            newPasswd=true;
        }catch(Exception e){
            System.debug('password incorrect');
            newPasswd=false;
        }
      return newPasswd;
    }
    
}