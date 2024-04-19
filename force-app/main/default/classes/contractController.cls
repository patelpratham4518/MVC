public with sharing class contractController {
	
    @AuraEnabled
    public static Account getAccountName(String accID){
        Account name = [Select Name from Account Where Id=:accID LIMIT 1];
        return name;
    }
    
    @AuraEnabled
    public static List<Custom_Contract__c> getContractDetails(){
        System.debug('Testing ===>>');
        List<Custom_Contract__c> contractData = new List<Custom_Contract__c>();
		contractData = [SELECT id,Name,Lastname__c,Billing_Address__c,Billing_City__c,Billing_Country__c,Billing_Pincode__c,Billing_State__c,Business_Unit__c,
                        comment__c,Customer_account_no__c,Customer_Name__r.Name,Email_Statement__c,Email__c,End_Date__c,FirstName__c,Phone__c,Purchasing_Group__c,
                        Schema_Name__c,Schema_Type__c,Shipping_Address__c,Shipping_City__c,Shipping_Country__c,Shipping_Pincode__c,Shipping_State__c,Signatory__c,Start_Date__c,
                        Tax_Identification_No__c,WholeSalerName__c FROM Custom_Contract__c LIMIT 4];
        return contractData;
    }
    
    @AuraEnabled
    public static List<Custom_Contract__c> getViewDetails(String record){
        System.debug('Testing record===>>');
        List<Custom_Contract__c> contractData = new List<Custom_Contract__c>();
		contractData = [SELECT id,Name,Lastname__c,Billing_Address__c,Billing_City__c,Billing_Country__c,Billing_Pincode__c,Billing_State__c,Business_Unit__c,comment__c,Customer_account_no__c,Customer_Name__r.Name,Email_Statement__c,Email__c,End_Date__c,FirstName__c,Phone__c,Purchasing_Group__c,Schema_Name__c,Schema_Type__c,Shipping_Address__c,Shipping_City__c,Shipping_Country__c,Shipping_Pincode__c,Shipping_State__c,Signatory__c,Start_Date__c,Tax_Identification_No__c,WholeSalerName__c FROM Custom_Contract__c Where id=:record];
        return contractData;
    }
    
    @AuraEnabled
    public static List<sales__c> getSalesList(String accId){
        System.debug('inside Salesjjd '+accId);
        return [Select id,Account__r.Name,Amount__c,Due_Date__c,Business_Unit__c,Status__c from sales__c Where Account__c=:accId];
    }
    
    @AuraEnabled
    public static List<Rebate__c> getRebateList(String accId){
        System.debug('sdjkfhjksdfhk');
        return [Select id,Start_Date__c,End_Date__c,Customer_Name__r.Name,Amount__c,Business_Unit__c,Country_Code__c,Rebate_Percentage__c from Rebate__c Where Customer_Name__c=:accId];
    }
    
    @AuraEnabled
    public static List<sales__c> getSearchResult(String abc,String uID){
        List<sales__c> salesRefinedList = new List<sales__c>();
        try{
            if(Date.valueof(abc)!=null){
            salesRefinedList = [Select id,Account__r.Name,Amount__c,Due_Date__c,Business_Unit__c,Status__c from sales__c Where Due_Date__c=:Date.valueof(abc) AND Account__c=:uID];
        }
        System.debug('Testing === >>> '+salesRefinedList);
        }catch(Exception e){
           salesRefinedList = [Select id,Account__r.Name,Amount__c,Due_Date__c,Business_Unit__c,Status__c from sales__c Where Account__c=:uID]; 
        }
        
        return salesRefinedList;
    }
    
    @AuraEnabled
    public static List<Rebate__c> getSearchRebateList(String startdt,String uID){
        List<Rebate__c> rebateList = new List<Rebate__c>();
        try{
            if(Date.valueof(startdt)!=null){
            	rebateList = [Select id,Start_Date__c,End_Date__c,Customer_Name__r.Name,Amount__c,Business_Unit__c,Country_Code__c,Rebate_Percentage__c from Rebate__c Where Start_Date__c=:Date.valueof(startdt) AND Customer_Name__c=:uID];
        	}
        }catch(Exception e){
           rebateList = [Select id,Start_Date__c,End_Date__c,Customer_Name__r.Name,Amount__c,Business_Unit__c,Country_Code__c,Rebate_Percentage__c from Rebate__c Where Customer_Name__c=:uID]; 
        }
        return rebateList;
    }
    @AuraEnabled
    public static String userDetails(){
        String uid = UserInfo.getUserId();
        User n = [Select ContactId,AccountId,Name from User Where Id=:uid];
        System.debug('User name === '+n.AccountId);
        String acc = n.AccountId;
    	return acc;
    }
    
   /* @AuraEnabled
    public static User userNameID(){
        System.debug('Testing userNameID');
        String uid = UserInfo.getUserId();
        User n = [Select ContactId,AccountId,Name from User Where Id=:uid];
        //System.debug('User name === '+n.AccountId);
        //String con = n.ContactId;
    	return n;
    }*/
}