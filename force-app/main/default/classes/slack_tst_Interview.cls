@isTest
public class slack_tst_Interview {
	@isTest 
	static void testTrigger() {
		Interviewer__c obj4 = new Interviewer__c();
		insert obj4;

		Contact obj3 = new Contact(
			LastName = 's'
		);
		insert obj3;

		Job_Application__c obj2 = new Job_Application__c(
			Contact__c = obj3.Id
		);
		insert obj2;

		Job_Posting__c obj1 = new Job_Posting__c(
			Job_Name__c = 's'
		);
		insert obj1;

		Interview__c obj0 = new Interview__c(
			Date__c = Date.today(),
			Time__c = Time.newInstance(1,2,3,4),
			Job_Posting__c = obj1.Id,
			Job_Application__c = obj2.Id,
			Interviewer__c = obj4.Id,
			Interview_Round_Name__c = 's'
		);
		insert obj0;
	}
}