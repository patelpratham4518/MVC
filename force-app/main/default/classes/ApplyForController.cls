public class ApplyForController {
  
  public Blob resume {get; set;}
  public String contentType {get; set;}
  public String fileName {get; set;}
  
  public  string fName {get; set;}
  public  string mName {get; set;}
  public  string lName {get; set;}
  public  string state {get; set;}
  public  string city  {get; set;}
  public  date   dob   {get; set;}
  public  Integer exp   {get; set;}
  public  string email {get; set;}
  public  string phone1 {get;set;}
  public  string phone2 {get;set;}
  public  string referenceName {get;set;}
  public  string noticePeriod {get;set;}   
  public  blob file {get; set;}
  public boolean check {get; set;}
 
  
  public  void doInit(){
      System.debug('lName'+lName);
      Contact contactList = new Contact();
      contactList.FirstName = fName;
      contactList.Middle_Name_del__c = mName;
      contactList.LastName = lName;
      contactList.State__c = state;
      contactList.City__c = city;
      contactList.DOB__c = dob;
      contactList.Experience__c = exp;
      contactList.Email = email;
      contactList.Phone = phone1;
      contactList.Alternate_Phone__c = phone2;
      contactList.Reference_Name__c = referenceName;
      contactList.Notice_Period__c = noticePeriod;
      if(check == true){
          contactList.Are_You_Ready_To_Relocate__c = 'YES';
      }
      else
      {
           contactList.Are_You_Ready_To_Relocate__c = 'NO';
      }
      
      insert contactList;
      system.debug('check::>>'+check);
      
      if(resume!=null){
            Attachment attach=new Attachment();
            attach.Body=resume;
            attach.Name=filename;
            attach.ContentType=contentType;
            attach.ParentID = contactList.id;
            try {
                insert(attach);
            } catch(System.DMLException e) {
                ApexPages.addMessages(e);
                
            }
        }
      
      
      system.debug('contactList::>>>>'+ contactList);
  }
}