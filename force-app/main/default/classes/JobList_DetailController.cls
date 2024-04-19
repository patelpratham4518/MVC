public class JobList_DetailController {
    public List<Job_Posting__c> jbLt {get;set;}
    public Boolean errorShow {get;set;}
    public JobList_DetailController(){
        JobList();
    }
    public void JobList(){
        jbLt = [SELECT Id,Name,Job_Name__c,Type__c FROM Job_Posting__c WHERE On_Off__c = true ORDER BY Name];
        System.debug(jbLt.size()+' size');
        if(jbLt.size() == null || jbLt.size() == 0){
            errorShow = true;
        }
        else{
            errorShow = false;
        }
    }
}