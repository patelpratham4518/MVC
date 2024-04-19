public class status {
    private final Application__c  applicant;
    public Blob resume {get; set;}
    public String contentType {get; set;}
    public String fileName {get; set;}
    
    public status() {
        //this.applicant=(Application__c )stdController.getRecord();
    }
    public PageReference saveApplication() {
        Contact conList = new Contact();
            conList.LastName  = 'Test';
        Insert conList;
          
        
        if(resume!=null){
            Attachment attach=new Attachment();
            attach.Body=resume;
            attach.Name=filename;
            attach.ContentType=contentType;
            attach.ParentID = conList.id;
            try {
                insert(attach);
            } catch(System.DMLException e) {
                ApexPages.addMessages(e);
                return null;
            }
        }
        //PageReference p = Page.Confirmpage;
        //p.setRedirect(true);
        return null;
    }
}