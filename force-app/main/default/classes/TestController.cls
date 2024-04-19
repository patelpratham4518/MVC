public class TestController {
    // INITIALIZE ALL VARIABLES
    public Integer totalIn {get;set;}//TOTAL OF INTERVIEWERS
	
    public TestController(){
        init();
        Main();
    }
    
    public void init(){
        
    }
    
    public void Main(){
        List<Interviewer__c> Inter = new List<Interviewer__c>();
        Inter = [SELECT Id,Name FROM Interviewer__c];
        totalIn = Inter.size();
    }

}