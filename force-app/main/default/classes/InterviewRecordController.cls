public class InterviewRecordController {
    
public Contact cont{get;set;}
public Candidate__c candidate{get;set;}
public String currentRecordCandidateId {get;set;}     
public string selectedStatus{get; set;}
public List<SelectOption> statusOptions{get;set;}

    
    public InterviewRecordController() {
        currentRecordCandidateId  = ApexPages.CurrentPage().getparameters().get('Id');
        String login  = ApexPages.CurrentPage().getparameters().get('authorized');
        
        if(login == 'yes'){
        	list<Job_Application__c> currentRecordContactId = [SELECT Contact__c FROM Job_Application__c WHERE Id =: currentRecordCandidateId LIMIT 1 ];
        
            //candidate = [SELECT Status__c FROM Candidate__c WHERE Id =: currentRecordCandidateId LIMIT 1 ];
            
            cont = [SELECT Id, Name, Email, MobilePhone, MailingStreet, Type_of_Degree__c,Gender__c, College_Name__c, Branch__c, CGPA_or_Percentage__c, Year_Of_Passing__c, Total_Experience__c 
                    FROM Contact 
                    WHERE Id =: currentRecordContactId[0].Contact__c ];
                    
            statusOptions = new List<SelectOption>();
            Schema.DescribeFieldResult fieldResult = Candidate__c.Status__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            statusOptions.add( new SelectOption('','--Select--'));
            for( Schema.PicklistEntry f : ple) {
                statusOptions.add(new SelectOption(f.getLabel(), f.getValue()));
            }    
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You are not authorized to this page'));   
        }        
        
    }
    
     public PageReference submit(){
        
        Candidate__c can = new Candidate__c();
        can.Id = currentRecordCandidateId;
        can.Status__c = selectedStatus;
        update can;
        candidate.Status__c = selectedStatus;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Record Update Successfully '));
        return null;
    }
}