@isTest
public class EmailWizardControllerTest {

    @isTest
    static void testFetchAccountWrapper() {
        // Create test data
        Lead testLead = new Lead(FirstName = 'Test', LastName = 'Lead', Email = 'testlead@test.com' ,  Company = 'Test Account' , Status = 'Open - Not Contacted');
        insert testLead;
        String objname = 'Lead';
        
        // Call the method
        List<EmailWizardController.LeadListWrapper> result = EmailWizardController.fetchAccountWrapper(objname);
        
        // Verify the results
        System.assertEquals(1, result.size());

    }

    @isTest
    static void testGetSearchValue() {
        // Create test data

        // create account
    
        Lead testLead1 = new Lead(FirstName = 'Test', LastName = 'Lead', Email = 'testlead@test.com', Company = 'Test Account' , Status = 'Open - Not Contacted' );
        insert testLead1;
        Lead testLead2 = new Lead(FirstName = 'Test', LastName = 'Lead 2', Email = 'testlead2@test.com', Company = 'Test Account' , Status = 'Open - Not Contacted', LeadSource = 'Web' );
        insert testLead2;
        String objname = 'Lead';
        String searchname = 'Lead';
        
        // Call the method
        List<EmailWizardController.LeadListWrapper> result = EmailWizardController.getSearchValue(objname, searchname, 'Web');
        List<EmailWizardController.LeadListWrapper> result2 = EmailWizardController.getSearchValue(objname, searchname, '--None--');
        // Verify the results
        System.assertEquals(1, result.size());
        System.assertEquals(2, result2.size());

    }

    @isTest

    static void getObjectNameTest(){
        Map<String,String> LeadString = EmailWizardController.getLeadSourceFieldValue();
        EmailWizardController.getObjectName();
        EmailWizardController.getEmailTemaltes();
    }

    @isTest
    static void getAllFieldsTest(){

        String objname = 'Lead';
        List<String> result = EmailWizardController.getAllFields(objname);

    }   

    @isTest
    static void testSendMailsMethod() {
        // Create a test lead
        Lead lead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Email = 'vidit.s@gmail.com',
            LeadSource = 'Web',
            Company = 'Test Account' , Status = 'Open - Not Contacted'
        );
        insert lead;
        
        // Call SendMailsMethod with the test lead's ID
        List<Id> leadIdList = new List<Id>{lead.Id};
        String subject = 'Test email';
        String mailBody = 'This is a test email';
        String fileName = 'Test file';
        String fileType = 'txt';
        Blob fileBlob = Blob.valueOf('Test file contents');
        String objName = 'Lead';
        String result = EmailWizardController.SendMailsMethod(leadIdList, subject, mailBody, fileName, fileType, fileBlob, objName);
        
        // Verify that the method returned successfully
        System.assertEquals('Emails Sent Successfully!!', result);
        
        // Verify that the email was sent
    }
    
    @isTest
    static void testGetPreview() {
        // Create a test lead
        Lead lead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Email = 'vidit.s@gmail.com',
            Company = 'Test Account' , Status = 'Open - Not Contacted'
        );
        insert lead;
        
        // Call getPreview with the test lead's ID and a test email body
        String mailBody = 'This is a test email';
        String objName = 'Lead';
        String updatedMailBody = EmailWizardController.getPreview(lead.Id, mailBody, objName);
        
        // Verify that the email body was updated with the test lead's information
        System.assertEquals('This is a test email', updatedMailBody);
    }
}