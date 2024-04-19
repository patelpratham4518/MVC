public class FeedBackController {
    
    public String Name {get;set;}
    public String Email {get;set;}
    public String issue {get;set;}
    public String topics {get;set;}
    public String comment {get;set;}
    public boolean intern {get;set;}
    public boolean friend {get;set;}
    public String inform {get;set;}
    public String clear {get;set;}
    public Feedback__c fb {get;set;}
    public Boolean error {get;set;}
    public String errormsg {get;set;}
    public Boolean thanks {get;set;}
    public Boolean check1 {get;set;}
    
    public FeedBackController() {
        error=false;
        thanks = false;
    }

    public void save(){

        Feedback__c fb = new Feedback__c();
        List<Feedback__c> fbList = new List<Feedback__c>();
        fbList = [SELECT Id,Name__c FROM Feedback__c WHERE Email__c =: Email ];

        if(fbList.size() > 0){
            error=true;
            errormsg = 'This Email is already submitted feedback';
        }else if(!Pattern.matches('[a-zA-Z0-9._-]+@[a-zA-Z]+.[a-zA-Z]{2,4}', Email)){
            error = true;
            errormsg='Please Enter Valid Email Address.';
        }else{
    
        fb.Name__c = Name;
        fb.Email__c = Email;
        fb.issue__c = issue;
        fb.topics__c = topics;
        fb.comment__c = comment;
        fb.Internship__c = intern;
        fb.friend__c = friend;
        fb.Informative__c = inform;
        fb.ClearIdeas__c = clear;
        insert fb;

        thanks =true;

        }

        System.debug(Name);
        System.debug(Email);
        System.debug(issue);
        System.debug(topics);
        System.debug(comment);
        System.debug(intern);
        System.debug(friend);
        System.debug(inform);
        System.debug(clear);


    }

}