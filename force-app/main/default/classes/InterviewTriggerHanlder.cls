public without sharing class InterviewTriggerHanlder {
    public  List<Interview__c>       recordNewList   =   new List<Interview__c>();
    public  List<Interview__c>       recordOldList   =   new List<Interview__c>();
    public  Map<Id,Interview__c>     recordNewMap    =   new Map<Id,Interview__c>();
    public  Map<Id,Interview__c>     recordOldMap    =   new Map<Id,Interview__c>();
    
    public  boolean isbefore, isAfter, isInsert, isUpdate, isDelete, isUndelete =   false;
    
    public  static  boolean recursion_flag_before   =   true;
    public  static  boolean recursion_flag_After    =   true;
    
    public InterviewTriggerHanlder(List<Interview__c> newList, List<Interview__c> oldList, Map<Id,Interview__c> newMap, Map<Id,Interview__c> oldMap, boolean is_Insert,  boolean is_Update,  boolean is_Delete,  boolean is_Undelete){
        this.recordNewList  =   newList;
        this.recordOldList  =   oldList;
        this.recordNewMap   =   newMap;
        this.recordOldMap   =   oldMap;
        this.isInsert       =   is_Insert;
        this.isUpdate       =   is_Update;
        this.isDelete       =   is_Delete;
        this.isUndelete     =   is_Undelete;
    }
    
    public void BeforeInsertEvent(){}
    
    public void BeforeUpdateEvent(){}
    
    public void BeforeDeleteEvent(){
        System.debug('before delete method');

        deleteEventwhenEventDelete();
    }
    
    public void AfterInsertEvent(){
        ScheduleInterviewclick();
    }
    
    public void AfterUpdateEvent(){
        FirstRoundStatusUpdate();
        SecondRoundStatusUpdate();
        onChangeInterviewer();
        onChangeSDateTime();
        // sendEmailonFailedResult();
        //updatejobposting();
    }
    
    public void AfterDeleteEvent(){
        System.debug('after delete method');
        //deleteEventwhenEventDelete();
    }
    
    public void AfterUndeleteEvent(){}
    
    public void FirstRoundStatusUpdate() {
        Set<ID> jobIdsPassed = new Set<ID>();
        Set<ID> jobIdsFailed = new Set<ID>();
        if(!recordNewList.isEmpty())
        	System.debug('recordNewList ----> '+recordNewList[0]);
        for(Interview__c inter : recordNewList){
            if(inter.RecordTypeId == '0126F0000022cwXQAQ' && inter.Result__c == 'Passed'){
            	jobIdsPassed.add(inter.Job_Application__c);
            }
            else if(inter.RecordTypeId == '0126F0000022cwXQAQ' && inter.Result__c == 'Failed'){
                jobIdsFailed.add(inter.Job_Application__c);
            }
        }
        List<ID> conIdsPassed = new List<ID>();
        List<ID> conIdsFailed = new List<ID>();
        for(Job_Application__c ja : [SELECT Id, Contact__c FROM Job_Application__c WHERE Id IN: jobIdsPassed AND Interview_Count__c = 1]){
            conIdsPassed.add(ja.Contact__c);
        }
        for(Job_Application__c ja : [SELECT Id, Contact__c FROM Job_Application__c WHERE Id IN: jobIdsFailed AND Interview_Count__c = 1]){
            conIdsFailed.add(ja.Contact__c);
        }
        List<Contact> upConList = new List<Contact>();
        if(!conIdsPassed.isEmpty()){
            for(Contact con : [SELECT Id, Name, Status__c FROM Contact WHERE ID IN: conIdsPassed]){
                if(con.Status__c != 'Selected in interview 1'){
                    con.Status__c = 'Selected in interview 1';
                    upConList.add(con);
                }
            }
        }
        if(!conIdsFailed.isEmpty()){
            for(Contact con : [SELECT Id, Name, Status__c FROM Contact WHERE ID IN: conIdsFailed]){
                if(con.Status__c != 'Rejected in interview 1'){
                    con.Status__c = 'Rejected in interview 1';
                    upConList.add(con);
                }
            }
        }
        System.debug('upConList Size ----> '+upConList.size());
        if(!upConList.isEmpty()){   System.debug('upConList ----> '+upConList[0]);update upConList;   }
    }

    public void SecondRoundStatusUpdate() {
        Set<ID> jobIdsPassed = new Set<ID>();
        Set<ID> jobIdsFailed = new Set<ID>();
        for(Interview__c inter : recordNewList){
            if(inter.RecordTypeId == '0126F0000022cwcQAA' && inter.Result__c == 'Passed'){
            	jobIdsPassed.add(inter.Job_Application__c);
            }
            else if(inter.RecordTypeId == '0126F0000022cwcQAA' && inter.Result__c == 'Failed'){
                jobIdsFailed.add(inter.Job_Application__c);
            }
        }
        List<ID> conIdsPassed = new List<ID>();
        List<ID> conIdsFailed = new List<ID>();
        for(Job_Application__c ja : [SELECT Id, Contact__c FROM Job_Application__c WHERE Id IN: jobIdsPassed AND Interview_Count__c = 1]){
            conIdsPassed.add(ja.Contact__c);
        }
        for(Job_Application__c ja : [SELECT Id, Contact__c FROM Job_Application__c WHERE Id IN: jobIdsFailed AND Interview_Count__c = 1]){
            conIdsFailed.add(ja.Contact__c);
        }
        List<Contact> upConList = new List<Contact>();
        if(!conIdsPassed.isEmpty()){
            for(Contact con : [SELECT Id, Name, Status__c FROM Contact WHERE ID IN: conIdsPassed]){
                if(con.Status__c != 'Selected in interview 2'){
                    con.Status__c = 'Selected in interview 2';
                    upConList.add(con);
                }
            }
        }
        if(!conIdsFailed.isEmpty()){
            for(Contact con : [SELECT Id, Name, Status__c FROM Contact WHERE ID IN: conIdsFailed]){
                if(con.Status__c != 'Rejected in interview 2'){
                    con.Status__c = 'Rejected in interview 2';
                    upConList.add(con);
                }
            }
        }
        if(!upConList.isEmpty()){   update upConList;   }
    }

    public void onChangeInterviewer(){
		String subject;
        // String subject = 'Interview Updated';
        List<Id> intids = new List<Id>();
        for(Interview__c interview : recordNewList){
            intids.add(interview.id);
        }
         Map<Id,Interview__c> intMap = new Map<Id,Interview__c>([SELECT Id,Job_Application__r.Contact__r.Email,Job_Application__r.Contact__r.FirstName,Date__c,Time__c,
                                                                    Job_Application__c,Interview_DateTime__c,Meeting_Link__c,Job_Posting__c,Contact_Email__c,Contact__r.email,Interviewer_Email__c,
                                                                    Interviewer__c,Interviewer__r.Email__c,Interview_Round_Name__c,CreatedDate From Interview__c WHERE Id IN: intids]);
        List<Interview__c> interNewlst = new List<Interview__c>();
        List<Interview__c> Interviewlist = new List<Interview__c>([Select Id,Date__c,Time__c,Job_Application__r.Contact__r.Email,Meeting_Link__c,Interviewer_Email__c,Contact_Email__c,Job_Application__r.Contact__r.Name,Contact__r.email,Interviewer__c,Interviewer__r.Email__c,Google_Event_ID__c,CreatedDate From Interview__c Where Id IN: intids]); 

        for(Interview__c intvar :Interviewlist){              
            subject = 'Interview Updated - ' + intvar.Job_Application__r.Contact__r.Name;
            System.debug('InterviewUpdated Suffix will be  ---___----> ' + subject);

    	}
        
        for(Interview__c inter :Interviewlist){      
             
            if(recordNewMap.get(inter.Id).Interviewer__c != recordOldMap.get(inter.id).Interviewer__c){   
                String tm = string.valueOf(inter.Time__c);    
                String[] strTimeSplit = tm.split(':');
                Time timeChange = Time.newInstance(Integer.valueOf(strTimeSplit[0]),Integer.valueOf(strTimeSplit[1]),0,0);
                String test = inter.Job_Application__r.Contact__r.Email;        		
                inter.Interviewer_Email__c = recordNewMap.get(inter.Id).Interviewer__r.Email__c;         
                System.debug('inter>>>'+inter);     
                interNewlst.add(inter);
                // scheduleinterview.interviewChange(inter.Interviewer__c,inter.Id);
                if (inter.Meeting_Link__c == true) {
                    scheduleinterview.interviewerChange(inter.Date__c,timechange, subject ,inter.Interviewer__c,test,inter.Id,inter.Google_Event_ID__c);
                    System.debug('interNewlst>>>'+interNewlst);
                }else{
                    scheduleinterview.updateEvent(inter.Date__c, timechange, subject, inter.Interviewer__c, test, inter.Id, inter.Google_Event_ID__c);
                }
            } 
        }        
         if(interNewlst.size() > 0){
            update interNewlst;
        }
    }

    public void onChangeSDateTime(){
		String subject;
        //String subject = 'Interview rescheduled';
        System.debug('Interview Rescheduled' );
        System.debug(recordNewList[0].Contact__c);
        System.debug(recordNewList[0].Contact__r.Name);
        List<Id> intIds = new List<Id>();
        for(Interview__c interview :recordNewList){
            intIds.add(interview.Id);
        }    
        List<Interview__c> Interviewlist = new List<Interview__c>([Select Id,Date__c,Time__c,Interviewer_Email__c,Google_Event_ID__c,Contact_Email__c,Interviewer__c,Contact__c,Job_Application__c,Job_Application__r.Contact__r.Email,Job_Application__r.Contact__r.Name, Meeting_Link__c From Interview__c Where Id IN: intIds]);

        for(Interview__c intvar :Interviewlist){              
            subject = 'Interview Rescheduled - ' + intvar.Job_Application__r.Contact__r.Name;
            System.debug('InterviewScheduled Suffix will be  ---___----> ' + subject);

    	}
        
        for(Interview__c inter :Interviewlist){              
            if((recordNewMap.get(inter.Id).Date__c != recordOldMap.get(inter.id).Date__c) || (recordNewMap.get(inter.Id).Time__c != recordOldMap.get(inter.id).Time__c)){    
        	    System.debug('recordNewMap>>>'+recordNewMap);
                System.debug('recordOldMap>>>'+recordOldMap);
                String tm = string.valueOf(inter.Time__c);    
                String[] strTimeSplit = tm.split(':');
                Time timeChange = Time.newInstance(Integer.valueOf(strTimeSplit[0]),Integer.valueOf(strTimeSplit[1]),0,0);
                String test = inter.Job_Application__r.Contact__r.Email;
                String subjecttest = inter.Job_Application__r.Contact__r.Name;
                System.debug('subjecttest ----> ' + subjecttest);
                if(inter.Meeting_Link__c == true)
                    // scheduleinterview.updateEvent(inter.Date__c, timechange, subject, inter.Interviewer__c, test, inter.Id, inter.Google_Event_ID__c);
                    scheduleinterview.onlineEvent(inter.Date__c, timechange, subject, inter.Interviewer__c, test, inter.Id, inter.Google_Event_ID__c);

                else 
                    scheduleinterview.updateEvent(inter.Date__c, timechange, subject, inter.Interviewer__c, test, inter.Id, inter.Google_Event_ID__c);
            }
    	}
    }
    public void updatejobposting(){
         Set<Id> sets = new Set<Id>();
        for(Interview__c interview :recordNewList){
            sets.add(interview.Id);
        }    
        List<Interview__c> Interviewlist1 = new List<Interview__c>();
        List<Interview__c> Interviewlist = new List<Interview__c>([Select Id,Interviewer_Email__c,Interviewer__c,Interviewer__r.Email__c,CreatedDate From Interview__c Where Id IN: sets]);
        System.debug('Interviewlist-->'+Interviewlist);   
        for(Interview__c interview1 :Interviewlist){     
            System.debug('interview1-->'+interview1);
            if(recordNewMap.get(interview1.Id).Job_Application__r.Job_Posting__c   != recordOldMap.get(interview1.id).Job_Application__r.Job_Posting__c ){           		
           	interview1.Job_Posting__c = interview1.Job_Application__r.Job_Posting__c ;          
                Interviewlist1.add(interview1);
                System.debug('interview1-->'+interview1);
            }
        }
        if(Interviewlist1.size() > 0){
            update Interviewlist1;
        }
    }

    public void ScheduleInterviewclick(){

        Set<Id> sets = new Set<Id>();
        for(Interview__c interview :recordNewList){
            sets.add(interview.Id);
        } 
        List<Interview__c> Interviewlist1 = new List<Interview__c>();
        List<Interview__c> Interviewlist = new List<Interview__c>([Select Id,Job_Application__r.Contact__r.Email,Job_Application__r.Contact__r.Name,Job_Application__r.Contact__r.FirstName,Date__c,Time__c,Job_Application__c,Interview_DateTime__c,Meeting_Link__c,Job_Posting__c,Contact_Email__c,Contact__r.email,Interviewer_Email__c,Interviewer__c,Interviewer__r.Email__c,Interview_Round_Name__c,CreatedDate From Interview__c Where Id IN: sets]);
        System.debug('Interviewlist-->'+Interviewlist);  
        // string reid = Interviewlist[0].Job_Application__c;
        string inter = Interviewlist[0].Interviewer__c;
        Date dt = Interviewlist[0].Date__c;
        String tm = string.valueOf(Interviewlist[0].Time__c);    
        String[] strTimeSplit = tm.split(':');
        Time timeChange = Time.newInstance( Integer.valueOf(strTimeSplit[0]),Integer.valueOf(strTimeSplit[1]),0,0);
        System.debug(timechange);
        // String tm = Interviewlist[0].Time__c;
        Boolean meetornot = Interviewlist[0].Meeting_Link__c;
        String round=Interviewlist[0].Interview_Round_Name__c;
        // String postid=Interviewlist[0].Job_Posting__c;
        String subject=round+' Round of Interview with - ' + Interviewlist[0].Job_Application__r.Contact__r.Name;
        String test=Interviewlist[0].Job_Application__r.Contact__r.Email;
        String interview=Interviewlist[0].Id;
        // System.debug('reid-->'+reid); 
        System.debug('inter-->'+inter); 
        System.debug('dt-->'+dt); 
        System.debug('timechange-->'+timechange); 
        System.debug('meetornot-->'+meetornot); 
        System.debug('Round-->'+round); 
        // System.debug('postid-->'+postid); 
        System.debug('subject:::'+subject);
        System.debug('test--->'+test);
        System.debug('interview--->'+interview);
        if(Interviewlist[0].Meeting_Link__c)
            scheduleinterview.createEvent(dt, timechange, subject ,inter,test,interview);
        else 
            scheduleinterview.createEventNotMeet(dt, timechange, subject ,inter,test,interview); 
        
    }

    public void deleteEventwhenEventDelete(){
        try {
            List<Interview__c> interviewees = new List<Interview__c>();
        Set<Id> sets = new Set<Id>();
        System.debug('in dele');
        System.debug('recordNewList>>>'+recordOldList);
        for(Interview__c interview :recordOldList){
            sets.add(interview.Id);
        } 
        System.debug('sets>>>'+sets);
        Interview__c interviewDetails = [
      
        SELECT Id, Date__c, Job_Posting__r.Job_Name__c, Interview_DateTime__c, Reporting_Date__c, Time__c, Result__c, Interviewer__c,
        Interviewer__r.Name, Interviewer__r.Email__c, Interviewer_Email__c, Job_Application__c,
        Job_Application__r.Job_Posting__c, Job_Application__r.Job_Posting__r.Job_Name__c, Job_Application__r.Contact__r.FirstName,
        Job_Application__r.Contact__r.LastName, Job_Application__r.Contact__r.Name, Job_Application__r.Contact__r.Email, Google_Event_ID__c
        FROM Interview__c
        WHERE Id IN : sets
    ];  System.debug('interviewDetails in delete event ---> '+interviewDetails);
        String tm = string.valueOf(interviewDetails.Time__c);
        String[] strTimeSplit = tm.split(':');
        String subject = 'Interview Deleted';
        
        Time timeChange = Time.newInstance(
        Integer.valueOf(strTimeSplit[0]),
        Integer.valueOf(strTimeSplit[1]),
        0,
        0
        );
        
        System.debug('cEvent ---> '+timeChange);

        String cEvent = interviewDetails.Job_Application__r.Contact__r.Email;
        System.debug('cEvent ---> '+cEvent);
        scheduleinterview.cancelEvent(interviewDetails.Date__c, timechange, subject, interviewDetails.Interviewer__c, cEvent, interviewDetails.Id, interviewDetails.Google_Event_ID__c );
        } catch (Exception e) {
            System.debug('The following exception has occured : ' + e.getMessage());
        }
        
    }

}