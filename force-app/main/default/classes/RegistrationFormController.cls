public class RegistrationFormController {
    public Contact ConObj {get;set;}
    
    public Boolean Status{get; set;}
    
    public static Blob resume {get; set;}
    public static String fileName{get; set;}
    public static String contentType{get; set;}
    
    public static Attachment attach {get;set;}
    
    public static Boolean isMobile { get; set; } 
    
    public static Map<String, String> errorMap {get;set;}
    public String currentJobPostingId {get;set;} 
    
    public Boolean Applied {get;set;}
     
    public RegistrationFormController(){
        ConObj = new Contact();
        attach = new Attachment();
        currentJobPostingId = '';
        currentJobPostingId  = ApexPages.CurrentPage().getparameters().get('jId');
        
        isMobile = UserInfo.getUiTheme() == 'Theme4t';
        status = true;
        Applied = false;
        clearErrorMap();
    }
    
    public PageReference Submit(){
        clearErrorMap();
        System.debug(ConObj);
        if(ConObj.FirstName == null || ConObj.FirstName == ''){
            errorMap.put('FirstName', 'This field is required');
            status = false;
        }else if(!Pattern.matches('[a-zA-Z ]+',ConObj.FirstName)){
            errorMap.put('FirstName', 'Enter valid First Name');
            status = false;
        }
        
        if(ConObj.LastName == null || ConObj.LastName == ''){
            errorMap.put('LastName', 'This field is required');
            status = false;
        }else if(!Pattern.matches('[a-zA-Z ]+', ConObj.LastName)){  
            errorMap.put('LastName', 'Enter valid Last Name');
            status = false;
        }
        
        if(ConObj.Gender__c == null || ConObj.Gender__c == ''){
            errorMap.put('Gender__c', 'This field is required');
            status = false;
        }
        
        if(ConObj.Email == null || ConObj.Email == ''){
            errorMap.put('Email', 'This field is required');
            status = false;
        }else if(!Pattern.matches('[a-zA-Z0-9._-]+@[a-zA-Z]+.[a-zA-Z]{2,4}', ConObj.Email)){
            errorMap.put('Email', 'Enter valid Email');
            status = false;
        }
        
        
        if(ConObj.MobilePhone == null || ConObj.MobilePhone == ''){
            errorMap.put('MobilePhone', 'This field is required');
            status = false;
        }else if(ConObj.MobilePhone.length()<10){
            errorMap.put('MobilePhone', 'Enter valid Mobile Number');
            status = false;
        }
        
        if(ConObj.Phone != null && ConObj.Phone.length()<10){
            errorMap.put('Phone', 'Enter valid Phone Number');
            status = false;
        }
        
        if(ConObj.Degree__c == null || ConObj.Degree__c == ''){
            errorMap.put('Degree__c', 'This field is required');
            status = false;
        }
        
        if(ConObj.Branch__c == null || ConObj.Branch__c == ''){
            errorMap.put('Branch__c', 'This field is required');
            status = false;
        }else if(!Pattern.matches('[a-zA-Z ]+', ConObj.Branch__c)){
            errorMap.put('Branch__c', 'Enter valid Branch');
            status = false;
        }
        
        if(ConObj.College_Name__c == null || ConObj.College_Name__c == ''){
            errorMap.put('College_Name__c', 'This field is required');
            status = false;
        }else if(!Pattern.matches('[a-zA-Z ]+', ConObj.College_Name__c)){
            errorMap.put('College_Name__c', 'Enter Valid College Name');
            status = false;
        }
        
        if(ConObj.Year_Of_Passing__c == null || ConObj.Year_Of_Passing__c == ''){
            errorMap.put('Year_Of_Passing__c', 'This field is required');
            status = false;
        }else if(!Pattern.matches('[0-9]+', ConObj.Year_Of_Passing__c)){
            errorMap.put('Year_Of_Passing__c', 'Enter valid Year Of Passing');
            status = false;
        }
        
        if(ConObj.CGPA_or_Percentage__c == null){
            errorMap.put('CGPA_or_Percentage__c', 'This field is required');
            status = false;
        }else if(Pattern.matches('[a-zA-Z]+', String.valueOf(ConObj.CGPA_or_Percentage__c))){
            errorMap.put('CGPA_or_Percentage__c', 'Enter valid CGPA/Percentage');
            status = false;
        }
        
        if(ConObj.Total_Experience__c == null){
            errorMap.put('Total_Experience__c', 'This field is required');
            status = false;
        }else if(Pattern.matches('[a-zA-Z]+', String.valueOf(ConObj.Total_Experience__c))){
            errorMap.put('Total_Experience__c', 'Enter valid Experience');
            status = false;
        }
        
        
        if(ConObj.Total_Experience__c != null && ConObj.Past_Company__c == null || ConObj.Total_Experience__c != null && ConObj.Past_Company__c == ''){
            errorMap.put('Past_Company__c', 'This field is required');
            status = false;
        }
        
        if(resume == null){
            errorMap.put('resume', 'Please upload resume');
            status = false;
        }
        
        if(status == false){
            status = true;
            return null;
        }else{
            clearErrorMap();
            List<Contact> conList = [ SELECT Id,FirstName,LastName,Email,Gender__c,MobilePhone,Phone,Degree__c,Branch__c,College_Name__c,Year_Of_Passing__c,CGPA_or_Percentage__c,Total_Experience__c,Past_Company__c,skills__c FROM contact WHERE email =: ConObj.Email LIMIT 1];
            
            System.debug(filename);
            if(!conList.isEmpty()){
                conList[0].FirstName = ConObj.FirstName;
                conList[0].LastName = ConObj.LastName;
                conList[0].Email = ConObj.Email;
                conList[0].Gender__c = ConObj.Gender__c;
                conList[0].MobilePhone = ConObj.MobilePhone;
                conList[0].Phone = ConObj.Phone;
                conList[0].Degree__c = ConObj.Degree__c;
                conList[0].Branch__c = ConObj.Branch__c;
                conList[0].College_Name__c = ConObj.College_Name__c;
                conList[0].Year_Of_Passing__c = ConObj.Year_Of_Passing__c;
                conList[0].CGPA_or_Percentage__c = ConObj.CGPA_or_Percentage__c;
                conList[0].Total_Experience__c = ConObj.Total_Experience__c;
                conList[0].Past_Company__c = ConObj.Past_Company__c;
                conList[0].skills__c = ConObj.skills__c;
                
                update conList[0];
                
                Attachment attach=new Attachment();  
                attach.Body=resume;
                attach.Name=fileName;
                attach.ContentType=contentType;
                attach.ParentID=conList[0].id;
                insert attach;
                
                
                if(currentJobPostingId != ''){
                    Job_Application__c JobApp = new Job_Application__c();
                    JobApp.Contact__c = conList[0].Id;
                    JobApp.Job_Posting__c = currentJobPostingId;
                    insert JobApp;  
                
                
                    Applied = true;
                    
                    String subjectGmail = 'Thank you for applying';
                    // String bodyGmail = 'Dear '+ConObj.FirstName+',<br /><br />Thank you for Registration.<br />A representative will contact you shortly.<br /><br />Best always,<br />MV Clouds<br /><br /><a href="https://mvclouds.com">Mv Clouds</a>';
                    String bodyGmail = '<p style="font-family:verdana !important;">Dear '+conList[0].FirstName+',<br /><br />'+
                            'Thanks for taking the time to apply for the position. We appreciate your interest in the <b>MV Clouds</b><br />'+
                            'If you are shortlisted then our HR will contact you in short time.<br />'+
                            'Meanwhile you can read more about our company on <a href="www.mvclouds.com">MV Clouds</a> or follow us on <a href="https://www.linkedin.com/company/mv-clouds-private-limited/">linkedin</a><br/><br />'+                            
                            'Regards,'+
                                
                                '<table style="font-family:verdana !important;">'+
                                    '<tbody>'+
                                        '<tr>'+
                                            '<td rowspan="3"><img src="https://dharmikmv-dev-ed--c.ap4.content.force.com/servlet/servlet.ImageServer?id=0156F00000IzcHP&amp;oid=00D6F0000029IuY&amp;lastMod=1599120562000" style="height:70px"/></td>'+
                                            '<td><strong>MV Clouds Private Limited</strong></td>'+
                                        '</tr>'+
                                        '<tr>'+
                                            '<td>info@mvclouds.com || <a href="http://www.mvclouds.com">www.mvclouds.com</a></td>'+
                                        '</tr>'+
                                        '<tr>'+
                                            '<td>'+
                                               '<p style="margin:0px!important">D-404, The First Synthesis, B/H Keshav Baugh Party Plot,<br /> Shivalik High-Street, Ahmedabad - 380015</p>'+
                                            '</td>'+
                                        '</tr>'+
                                    '</tbody>'+
                                '</table><p>';
                                
                    String sendTo = conList[0].FirstName+ ' ' + conList[0].LastName + '<'+ conList[0].Email +'>';
                    
                    GoogleGmailApi.sendGmail(subjectGmail,bodyGmail,sendTo);
                    
                    
                    String subjectGmailToInfo = 'New Application Arrived';
                    String subjectBodyGmailToInfo = '<p style="font-family:verdana !important;">A new application arrived <br /><br />'+
                                'Name:- '+conList[0].FirstName + ' ' + conList[0].LastName + '<br />' +
                                'Email:- ' +conList[0].Email + '<br />'+ 
                                'Mobile:- '+conList[0].MobilePhone + '<br />' +
                                '<br /><br /></p>'+
                        		'<a href="https://dharmikmvclouds-developer-edition.ap4.force.com/demo?id='+JobApp.Id+'">Click here to schedule the interview Date & Time.</a>';
                    
                    String sendToInfo = 'MV Clouds<akshay.c@mvclouds.com>';
                    GoogleGmailApi.sendGmailWithAttachment(subjectGmailToInfo,subjectBodyGmailToInfo,sendToInfo,attach.Id+'');
                    ConObj = new Contact();
                    resume = Blob.valueOf('');
                    filename = '';
                    contentType = '';
                }
                
                
                
            }else{
                insert ConObj;
                
                Attachment attach=new Attachment();  
                attach.Body=resume;
                attach.Name=fileName;
                attach.ContentType=contentType;
                attach.ParentID=ConObj.id;
                insert attach; 
                
                if(currentJobPostingId != ''){
                    Job_Application__c JobApp = new Job_Application__c();
                    JobApp.Contact__c = ConObj.Id;
                    JobApp.Job_Posting__c = currentJobPostingId;
                    insert JobApp;  
                
                Applied = true;
                String subjectGmail = 'Thank you for applying';
                // String bodyGmail = 'Dear '+ConObj.FirstName+',<br /><br />Thank you for Registration.<br />A representative will contact you shortly.<br /><br />Best always,<br />MV Clouds<br /><br /><a href="https://mvclouds.com">Mv Clouds</a>';
                String bodyGmail = '<p style="font-family:verdana !important;">Dear '+ConObj.FirstName+',<br /><br />'+
                        'Thanks for taking the time to apply for the position. We appreciate your interest in the <b>MV Clouds</b><br />'+
                        'If you are shortlisted then our HR will contact you in short time.<br />'+
                        'Meanwhile you can read more about our company on <a href="www.mvclouds.com">MV Clouds</a> or follow us on <a href="https://www.linkedin.com/company/mv-clouds-private-limited/">linkedin</a><br/><br />'+
                        'Regards,'+
                            
                            '<table style="font-family:verdana !important;">'+
                                '<tbody>'+
                                    '<tr>'+
                                        '<td rowspan="3"><img src="https://dharmikmv-dev-ed--c.ap4.content.force.com/servlet/servlet.ImageServer?id=0156F00000IzcHP&amp;oid=00D6F0000029IuY&amp;lastMod=1599120562000" style="height:70px"/></td>'+
                                        '<td><strong>MV Clouds Private Limited</strong></td>'+
                                    '</tr>'+
                                    '<tr>'+
                                        '<td><a href="maito:info@mvclouds.com">info@mvclouds.com</a> || <a href="http://www.mvclouds.com">www.mvclouds.com</a></td>'+
                                    '</tr>'+
                                    '<tr>'+
                                        '<td>'+
                                           '<p style="margin:0px!important">D-404, The First Synthesis, B/H Keshav Baugh Party Plot,<br /> Shivalik High-Street, Ahmedabad - 380015</p>'+
                                        '</td>'+
                                    '</tr>'+
                                '</tbody>'+
                            '</table><p>';
                            
                String sendTo = ConObj.FirstName+ ' ' + ConObj.LastName + '<'+ ConObj.Email +'>';
                
                GoogleGmailApi.sendGmail(subjectGmail,bodyGmail,sendTo);
                
                
                String subjectGmailToInfo = 'New Application Arrived';
                String subjectBodyGmailToInfo = '<p style="font-family:verdana !important;">A new application arrived <br /><br />'+
                            'Name:- '+ConObj.FirstName + ' ' + ConObj.LastName + '<br />' +
                            'Email:- ' +ConObj.Email + '<br />'+ 
                            'Mobile:- '+ConObj.MobilePhone + '<br />' +
                            '<br /><br />'+
                    		'<a href="https://dharmikmvclouds-developer-edition.ap4.force.com/demo?id='+JobApp.Id+'">Click here to schedule the interview Date & Time.</a>';
                
                String sendToInfo = 'MV Clouds<akshay.c@mvclouds.com>';
                GoogleGmailApi.sendGmailWithAttachment(subjectGmailToInfo,subjectBodyGmailToInfo,sendToInfo,attach.Id+'');
                ConObj = new Contact();
                resume = Blob.valueOf('');
                filename = '';
                contentType = '';
               }
            }
        }
        
        // PageReference retURL = new PageReference('/apex/ThankYou');
        // retURL.setRedirect(true);
        return null;
    }
    
    public void clearErrorMap(){
        errorMap = new Map<String, String>();
        errorMap.put('FirstName','');
        errorMap.put('LastName','');
        errorMap.put('Email','');
        errorMap.put('Gender__c','');
        errorMap.put('MobilePhone','');
        errorMap.put('Phone','');
        errorMap.put('Degree__c','');
        errorMap.put('Branch__c','');
        errorMap.put('College_Name__c','');
        errorMap.put('Year_Of_Passing__c','');
        errorMap.put('CGPA_or_Percentage__c','');
        errorMap.put('Total_Experience__c','');
        errorMap.put('Past_Company__c','');
        errorMap.put('skills__c','');
        errorMap.put('resume','');
    }
}