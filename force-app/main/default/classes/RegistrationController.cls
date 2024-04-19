public class RegistrationController {
    private Contact con;
    private Candidate__c candidate;
    private Job_Posting__c JobPostingId;
    public String currentJobPostingId {get;set;} 
    public static Contact cont {get; set;}
    public String FirstName{get;set;}
    public String LastName{get;set;}
    public String Email{get;set;}
    public String Mobile{get;set;}
    public String CollegeName{get;set;}
    public String Branch{get;set;}
    public String YearOfPassing{get;set;}
    public String CGPA{get;set;}
    public String Experience{get;set;}    
    public String Reference{get;set;}
    public String selectedDegree{get;set;}
    public String selectedGender{get;set;}
    public String Title{get;set;}
    public Boolean status{get; set;}
    public Blob resume {get; set;}
    public String fileName{get; set;}
    public String contentType{get; set;}
    public Blob csvBlob {get; set;}
    public String csvName{get; set;}
    public boolean displayPopup {get; set;}
    public boolean isMobile{get; set;}

    
    public RegistrationController()
    {
        currentJobPostingId  = ApexPages.CurrentPage().getparameters().get('jId');
        status = true;
        String userAgent = System.currentPageReference().getHeaders().get('User-Agent');
        isMobile = UserInfo.getUiTheme() == 'Theme4t';
    }
    public PageReference submit(){
  
        if(!Pattern.matches('[a-zA-Z ]+',FirstName) || FirstName == null){
        
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Enter valid First Name');
            ApexPages.addMessage(msg);
            status = false;
        }
        if(!Pattern.matches('[a-zA-Z ]+', LastName) || LastName == null){  
        
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Enter valid Last Name');
            ApexPages.addMessage(msg);
            status = false;
        }
        if(!Pattern.matches('[a-zA-Z0-9._-]+@[a-zA-Z]+.[a-zA-Z]{2,4}', Email) || Email == null){
        
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Enter valid Email');
            ApexPages.addMessage(msg);
            status = false;
        }
        if(Mobile.length()!=10 || Mobile == null){
        
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Enter valid Phone Number');
            ApexPages.addMessage(msg);
            status = false;
        }
        if(selectedGender == null){
        
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Please Select Gender');
            ApexPages.addMessage(msg);
            status = false;
        }
        if(selectedDegree == null){
        
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Please Select Degree');
            ApexPages.addMessage(msg);
            status = false;
        }
        if(!Pattern.matches('[a-zA-Z ]+', CollegeName) || CollegeName == null){
        
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Enter valid College Name');
            ApexPages.addMessage(msg);
            status = false;
        }
        if(!Pattern.matches('[a-zA-Z ]+', Branch) || Branch == null){
        
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Enter valid Branch');
            ApexPages.addMessage(msg);
            status = false;
        }
        if(!Pattern.matches('[0-9]+', YearOfPassing) || YearOfPassing == null){
        
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Enter valid Year Of Passing');
            ApexPages.addMessage(msg);
            status = false;
        }
        if(Pattern.matches('[a-zA-Z]+', String.valueOf(CGPA)) || CGPA == null){
        
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Enter valid CGPA/Percentage');
            ApexPages.addMessage(msg);
            status = false;
        }
        if(!Pattern.matches('[0-9]+', Experience) || Experience == null){
        
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Enter valid Experience ');
            ApexPages.addMessage(msg);
            status = false;
        }
        if(status == false){
            status = true;
            return null;
        }
		        
        list<Contact> emailcheck = [ SELECT Id,FirstName,LastName,Email,MobilePhone FROM contact WHERE email =: Email LIMIT 1];
        
        System.debug('EmailCheck == >'+ emailcheck+'sendNotifications'+Email);
        
        if(emailcheck.size() > 0 != true)
        {
            Contact con = new Contact();
            con.FirstName = FirstName;
            con.LastName = LastName;
            con.Email = Email;
            con.MobilePhone = Mobile;
            con.College_Name__c = CollegeName;
            con.Branch__c = Branch;  
            con.Year_Of_Passing__c = YearOfPassing;
            con.CGPA_or_Percentage__c = Decimal.valueOf(CGPA);
            con.Total_Experience__c = Experience;
            con.Reference_Name__c = Reference;
            con.Title = Title;
            con.Gender__c = selectedGender;
            con.Type_of_Degree__c = selectedDegree;
        
            insert con;
        
            Attachment attach=new Attachment();  
            attach.Body=resume;
            attach.Name=fileName;
            attach.ContentType=contentType;
            attach.ParentID=con.id;
            insert attach;   
            
            Candidate__c candidate = new Candidate__c();
            candidate.Contact__c = con.id;
            candidate.Job_Posting__c = currentJobPostingId;
            candidate.Status__c = 'Interviewing';
            System.debug('currentJobPostingId ==>'+currentJobPostingId);
            insert candidate;
            
            String subjectGmail = 'Registration Successful';
            String bodyGmail = 'Dear '+con.FirstName+',<br /><br />Thank you for Registration.<br />A representative will contact you shortly.<br /><br />Best always,<br />MV Clouds<br /><br /><a href="https://mvclouds.com">Mv Clouds</a>';
            String sendTo = con.FirstName+ ' ' + con.LastName + '<'+ con.Email +'>';
            
            GoogleGmailApi.sendGmail(subjectGmail,bodyGmail,sendTo);
            
            String subjectGmailForInterviewer = 'Invitation for Interview';
            String bodyGmailForInterviewer = '<b>Invitation: Interview with<b> ' + con.FirstName + '<br/> Please call<b> ' + con.FirstName +' </b>and confirm the schedule for the interview.<p><br/> Name : ' + con.FirstName + '<br/>Email : ' + con.Email + '<br/>Mobile : ' + con.MobilePhone + '<br/>' + con.FirstName + ' is ready for the interview then click the link and set the interview date and time.<p><br/> <a href="https://dharmikmvclouds-developer-edition.ap4.force.com/InterviewScheduleFirst?Id='+candidate.Id+'">Click here to schedule the interview Date & Time.</a>';
            String sendToInterviewer = 'kushal.b@mvclouds.com';
            
            GoogleGmailApi.sendGmailWithAttachment(subjectGmailForInterviewer,bodyGmailForInterviewer,sendToInterviewer,attach.Id+''); 
          
        }
        else{
            
            emailcheck[0].FirstName = FirstName;
            emailcheck[0].LastName = LastName;
            emailcheck[0].Email = Email;
            emailcheck[0].MobilePhone = Mobile;
            emailcheck[0].College_Name__c = CollegeName;
            emailcheck[0].Branch__c = Branch;  
            emailcheck[0].Year_Of_Passing__c = YearOfPassing;
            emailcheck[0].CGPA_or_Percentage__c = Decimal.valueOf(CGPA);
            emailcheck[0].Total_Experience__c = Experience;
            emailcheck[0].Reference_Name__c = Reference;
            emailcheck[0].Title = Title;
            emailcheck[0].Gender__c = selectedGender;
            emailcheck[0].Type_of_Degree__c = selectedDegree;
            update emailcheck[0];
            
            
            Candidate__c candidate = new Candidate__c();
            candidate.Contact__c = emailcheck[0].Id;
            candidate.Job_Posting__c = currentJobPostingId;
            candidate.Status__c = 'Interviewing';
            insert candidate;
            
            Attachment attach=new Attachment();  
            attach.Body=resume;
            attach.Name=fileName;
            attach.ContentType=contentType;
            attach.ParentID=emailcheck[0].id;
            insert attach;  
            
            
            String subjectGmail = 'Registration Successful';
            String bodyGmail = 'Dear '+emailcheck[0].FirstName+',<br /><br />Thank you for Registration.<br />A representative will contact you shortly.<br /><br />Best always,<br />MV Clouds<br /><br /><a href="https://mvclouds.com">Mv Clouds</a>';
            String sendTo = emailcheck[0].FirstName+ ' ' + emailcheck[0].LastName + '<'+ emailcheck[0].Email +'>';
            String attachStr = attach.Body+'';
            
            GoogleGmailApi.sendGmail(subjectGmail,bodyGmail,sendTo);
            
            String subjectGmailForInterviewer = 'Invitation for Interview';
            String bodyGmailForInterviewer = '<b>Invitation: Interview with<b> ' + emailcheck[0].FirstName + '<br/> Please call<b> ' + emailcheck[0].FirstName +' </b>and confirm the schedule for the interview.<p><br/> Name : ' + emailcheck[0].FirstName + '<br/>Email : ' + emailcheck[0].Email + '<br/>Mobile : ' + emailcheck[0].MobilePhone + '<br/>' + emailcheck[0].FirstName + ' is ready for the interview then click the link and set the interview date and time.<p><br/> <a href="https://dharmikmvclouds-developer-edition.ap4.force.com/InterviewScheduleFirst?Id='+candidate.Id+'">Click here to schedule the interview Date & Time.</a>';
            String sendToInterviewer = 'kushal.b@mvclouds.com';
             
            GoogleGmailApi.sendGmailWithAttachment(subjectGmailForInterviewer,bodyGmailForInterviewer,sendToInterviewer,attach.Id+'');
            
        }
        
        FirstName = '';
        LastName = '';
        selectedGender = '';
        Email = ''; 
        Mobile = '';
        selectedDegree = '';
        CollegeName = '';
        Branch  = '';
        YearOfPassing = '';
        CGPA = ''; 
        Experience = '';
        Reference = '';
        Title = '';
        PageReference retURL = new PageReference('/apex/ThankYou');
        retURL.setRedirect(true);
        return retURL;
    }
    
    public List<SelectOption> getDegreeOptions() {
        List<SelectOption> DegreeOptions = new List<SelectOption>();
        DegreeOptions.add(new SelectOption('','-None-'));
        DegreeOptions.add(new SelectOption('B.E','B.E'));
        DegreeOptions.add(new SelectOption('Diploma','Diploma'));
        DegreeOptions.add(new SelectOption('M.tech/M.E','M.tech/M.E'));
        
        return DegreeOptions;
    }
    
    public List<SelectOption> getGenderOptions() {
        List<SelectOption> GenderOptions = new List<SelectOption>();
        GenderOptions.add(new SelectOption('','-None-'));
        GenderOptions.add(new SelectOption('MALE','Male'));
        GenderOptions.add(new SelectOption('FEMALE','Female'));
        
        return GenderOptions;
    }
}