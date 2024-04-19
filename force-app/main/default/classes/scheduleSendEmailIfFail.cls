/**
 * Class is not in a use. Created for scheduling Failed result email sent.
 */

public class scheduleSendEmailIfFail implements schedulable{
    public static List<Interview__c> intList = new List<Interview__c>();
    public void execute(SchedulableContext sc){
        // SendEmailIfFail semail = new SendEmailIfFail();
        SendEmailIfFail.sendEmail(intList);
    }
}