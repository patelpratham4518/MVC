@isTest
public class MVCloudsPortalControllerTest {
    @isTest public static void LoginCheck(){
        MVCloudsPortalController Mpc= new MVCloudsPortalController();
        String s=MVCloudsPortalController.loginAuthentication('test@test.com','1234567');
        Employee__c epc= new Employee__c(Email__c='test@test.com',Password__c='tese');
    }
   static testMethod void fetchUser(){
        Contact maleContact = new Contact(
            FirstName = 'John',
            LastName = 'Smith'
        );
        insert maleContact;
    
        User usr = new User(
            Id = UserInfo.getUserId(),
            ContactId = maleContact.Id
        );
    
        System.runAs(usr){
            update usr;
        }
        MVCloudsPortalController obj01 = new MVCloudsPortalController();
    
        Test.startTest();
        user result = MVCloudsPortalController.fetchUser();
        Boolean result2 = MVCloudsPortalController.checkPass('test');
        System.assertEquals(false,result2);
        result2 = MVCloudsPortalController.checkPass('');
        Test.stopTest();
    }
    
    @isTest public static void checkpass(){
        
    }
}