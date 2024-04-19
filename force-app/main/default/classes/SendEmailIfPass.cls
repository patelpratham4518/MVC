public class SendEmailIfPass {

  @InvocableMethod
  public static void sendEmail(List<Interview__c> interviewees) {
    System.debug(interviewees[0]);
    System.debug(interviewees[0].Id);
    Id ids = interviewees[0].Id;
    System.debug(ids);
    Interview__c interviewDetails = [
      SELECT Id, Date__c, Job_Posting__r.Job_Name__c, Interview_DateTime__c, Reporting_Date__c, Time__c, Result__c, Interviewer__c, Interviewer__r.Name, Interviewer__r.Email__c, Interviewer_Email__c, RecordType.Name,
        Job_Application__c, Job_Application__r.Job_Posting__c, Job_Application__r.Job_Posting__r.Job_Name__c, Job_Application__r.Contact__r.FirstName, Job_Application__r.Contact__r.LastName,
        Job_Application__r.Contact__r.Name, Job_Application__r.Contact__r.Email, Google_Event_ID__c
      FROM Interview__c
      WHERE Id = :ids
      LIMIT 1
    ];
    System.debug('interviewDetails :: ' + interviewDetails);

    EmailTemplate emailtemplate1 = [
      SELECT Id, Subject, Description, name, HtmlValue, DeveloperName, Body
      FROM EmailTemplate
      WHERE Name = 'Your application status'
    ];
    System.debug('emailtemplate ==>' + emailtemplate1);

    EmailTemplate emailtemplate = [
      SELECT Id, Subject, Description, name, HtmlValue, DeveloperName, Body
      FROM EmailTemplate
      WHERE Name = 'Not Appered Mail'
    ];
    System.debug('emailtemplate ==>' + emailtemplate);

    EmailTemplate emailtemplate2 = [
      SELECT Id, Subject, Description, name, HtmlValue, DeveloperName, Body
      FROM EmailTemplate
      WHERE Name = 'Selected'
    ];
    System.debug('emailtemplate ==>' + emailtemplate2);

    // For Passed
    if (interviewDetails.Result__c == 'Passed') {
      String subjectGmail = 'Passed Interview';

      String bodyGmail =
        'Hi Maitri,<br/>' +
        interviewDetails.Job_Application__r.Contact__r.FirstName +
        ' ' +
        interviewDetails.Job_Application__r.Contact__r.LastName +
        ' have passed interview.<br/><br/>' +
        'Schedule Second Round:- <a href="https://dharmikmvclouds-developer-edition.ap4.force.com/demo?id=' +
        interviewDetails.Job_Application__r.Id +
        '">Click here to schedule the interview Date & Time.</a>';

      String bodyGmail1 =
        'Hi Hetavi,<br/>' +
        '<a href="' +
        System.URL.getSalesforceBaseUrl().toExternalForm() +
        '/lightning/r/Contact/' +
        interviewDetails.Job_Application__r.Contact__r.Id +
        '/view">' +
        interviewDetails.Job_Application__r.Contact__r.Name +
        '</a>' +
        ' have passed interview. Schedule next Round';

      System.debug('bodyGmail1-------------->' + bodyGmail1);

      String sendTo1 =
        'HR-MV Clouds<hetavi.s@mvclouds.com>' +
        ',' +
        'maitri.s@mvclouds.com';
      // String sendTo1 = 'Naimish Kalena<naimish.k@mvclouds.com>';
      System.debug(sendTo1);
      GoogleGmailApi.sendGmail(subjectGmail, bodyGmail1, sendTo1);
    }

    if (
      interviewDetails.Result__c == 'Passed' &&
      interviewDetails.RecordType.Name == 'Second Round'
    ) {
      String subjectGmail = 'Passed Interview';

      String bodyGmail =
        'Hi Dharmik,<br/>' +
        interviewDetails.Job_Application__r.Contact__r.Name +
        ' have passed interview.<br/><br/>' +
        'Please do further process.';

      String sendTo = 'Dharmik Shah<dharmik@mvclouds.com>';
      System.debug(sendTo);
      GoogleGmailApi.sendGmail(subjectGmail, bodyGmail, sendTo);
    }

    // For Failed

    if (interviewDetails.Result__c == 'Failed') {
      String subjectGmail = 'Your application status';

      String bodyGmail = emailtemplate1.HtmlValue;
      System.debug('bodyGmail::' + bodyGmail);
      bodyGmail =
        'Hi Hetavi,<br/>' +
        interviewDetails.Job_Application__r.Contact__r.Name +
        ' has been rejected in the interview.';
      
      System.debug('bodyGmail::' + bodyGmail);

      String sendTo =
        'HR-MV Clouds<hetavi.s@mvclouds.com>' +
        ',' +
        'maitri.s@mvclouds.com';
      // String sendTo = 'Naimish Kalena<naimish.k@mvclouds.com>';

      System.debug(sendTo);
      GoogleGmailApi.sendGmail(subjectGmail, bodyGmail, sendTo);
    }

    // For Not Seen

    if (interviewDetails.Result__c == 'Not seen') {
      String subjectGmail = 'Interview with MV Clouds Pvt. Ltd';

      String bodyGmail = emailtemplate.HtmlValue;
      System.debug('bodyGmail::' + bodyGmail);
      bodyGmail = bodyGmail.replace(
        '{!Interview__c.Job_Application__r.Contact__r.Name}',
        interviewDetails.Job_Application__r.Contact__r.Name
      );
      bodyGmail = bodyGmail.replace(
        '{!Interview__c.Job_Application__r.Job_Posting__r.Job_Name__c}',
        interviewDetails.Job_Application__r.Job_Posting__r.Job_Name__c
      );
      System.debug('bodyGmail::' + bodyGmail);

      String sendTo =
        interviewDetails.Job_Application__r.Contact__r.Name +
        '<' +
        interviewDetails.Job_Application__r.Contact__r.Email +
        '>' +
        ',' +
        'HR-MV Clouds<hetavi.s@mvclouds.com>';
      // String sendTo = 'Naimish Kalena<naimish.k@mvclouds.com>';

      System.debug(sendTo);
      GoogleGmailApi.sendGmailwithCCSelect_single(
        subjectGmail,
        bodyGmail,
        sendTo
      );
    }

    if (interviewDetails.Result__c == 'Selected') {
      String datetochange = String.valueOf(interviewDetails.Reporting_Date__c);
      String[] datevar = datetochange.split(' ');
      String subjectGmail = 'Congratulations! Welcome to MV Clouds Pvt. Ltd.';
      String bodyGmail = emailtemplate2.HtmlValue;
      System.debug('bodyGmail::' + bodyGmail);
      bodyGmail = bodyGmail.replace(
        '{!Contact.Name}',
        interviewDetails.Job_Application__r.Contact__r.Name
      );
      bodyGmail = bodyGmail.replace('{!Interview__c.Date__c}', datevar[0]);
      bodyGmail = bodyGmail.replace(
        '{!Interview__c.Job_Posting__c.Job_Name_c}',
        interviewDetails.Job_Application__r.Job_Posting__r.Job_Name__c
      );
      System.debug('bodyGmail::' + bodyGmail);

      String sendTo =
        interviewDetails.Job_Application__r.Contact__r.Name +
        '<' +
        interviewDetails.Job_Application__r.Contact__r.Email +
        '>' +
        ',' +
        'dharmik@mvclouds.com' +
        ',' +
        'maitri.s@mvclouds.com';        
      // String sendTo = 'Naimish Kalena<naimish.k@mvclouds.com>';

      System.debug(sendTo);
      GoogleGmailApi.sendGmailwithCCSelect(subjectGmail, bodyGmail, sendTo);
    }
    if (interviewDetails.Result__c == 'Cancelled') {
      System.debug('cancelled');
      String subject = 'Interview Cancelled';
      String tm = string.valueOf(interviewDetails.Time__c);
      String[] strTimeSplit = tm.split(':');
      Time timeChange = Time.newInstance(
        Integer.valueOf(strTimeSplit[0]),
        Integer.valueOf(strTimeSplit[1]),
        0,
        0
      );
      String test = interviewDetails.Job_Application__r.Contact__r.Email;
      scheduleinterview.cancelEvent(
        interviewDetails.Date__c,
        timechange,
        subject,
        interviewDetails.Interviewer__c,
        test,
        interviewDetails.Id,
        interviewDetails.Google_Event_ID__c
      );
    }
  }
}