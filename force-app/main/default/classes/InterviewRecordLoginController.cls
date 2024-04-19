public class InterviewRecordLoginController {
    
    public String currentRecordCandidateId{get;set;}
    public String UserID{get;set;}
	public String UPassword{get;set;}
    
    public InterviewRecordLoginController(){
     	currentRecordCandidateId  = ApexPages.CurrentPage().getparameters().get('Id');
        if(currentRecordCandidateId == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error : Please reopen the page'));
        }
    }
    
    public Pagereference doLogin(){
        if(currentRecordCandidateId == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error : Please reopen the page'));
            return null;
        }else{
        	if(UserID == 'admin' && UPassword == 'admin'){
                Pagereference pr = new PageReference('/apex/InterviewRecord');
                pr.getParameters().put('Id',currentRecordCandidateId);
                pr.getParameters().put('authorized','yes');
                pr.setReDirect(true);
                return pr;
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter valid details'));   
                return null;
            }    
        }
        
    }
	
}