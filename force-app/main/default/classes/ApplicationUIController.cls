public without sharing class ApplicationUIController {
  @AuraEnabled
  public static Job_Posting__c getPostingName(String posting) {
    Job_Posting__c jb = [
      SELECT ID, Job_Name__c, On_Off__c
      FROM Job_Posting__c
      WHERE Id = :posting
      LIMIT 1
    ];
    return jb;
  }

  @AuraEnabled
  public static String submitContact(
    String fileName,
    String base64Data,
    String contentType,
    String FirstName,
    String LastName,
    String Email,
    String Gender,
    String Mobile,
    Decimal Experience,
    String jobPosting,
    String FreshorExp,
    String currentcity,
    String state,
    String permanentcity,
    String percity,
    String relocate,
    Date dateOfBirth,
    String Month
  ) {
    EmailTemplate emailtemplate = [
      SELECT Id, Subject, Description, name, HtmlValue, DeveloperName, Body
      FROM EmailTemplate
      WHERE Name = 'Thank You For Applying'
    ];
    List<Contact> oldCon = [
      SELECT
        ID,
        FirstName,
        LastName,
        Email,
        Gender__c,
        MobilePhone,
        Experience__c
      FROM Contact
      WHERE Email = :Email
    ];
    if (oldCon.isEmpty()) {
      Contact con = new Contact();
      con.FirstName = FirstName;
      con.LastName = LastName;
      con.Email = Email;
      con.MobilePhone = Mobile;
      con.Gender__c = Gender;
      con.State__c = state;
      con.City__c = currentcity;
      con.It_is_your_p__c = permanentcity;
      con.Birthdate = dateOfBirth;
      con.Are_You_Ready_To_Relocate__c = relocate;
      con.Apply_through_form__c = true;
      //   con.Thank_You_Email__c = TRUE;
      //  con.Candidate_Experience__c = Month;
      if (FreshorExp == 'Fresher') {
        con.Experience_Pick__c = 'Fresher';
      }
      if (FreshorExp == 'Experienced') {
        con.Experience_Pick__c = Month;
      }
      if (permanentcity == 'Yes') {
        con.Permanent_city__c = currentcity;
      }
      if (permanentcity == 'No') {
        con.Permanent_city__c = percity;
      }
      insert con;

      Job_Application__c JobApp = new Job_Application__c();
      JobApp.Contact__c = con.Id;
      JobApp.Job_Posting__c = jobPosting;
      // JobApp.Job_Posting__c = 'a0EN000000JK16TMAT';
      insert JobApp;

      Job_Application__c jobpost = [
        SELECT Id, Job_Posting__r.Job_Name__c, Name
        FROM Job_Application__c
        WHERE Id = :JobApp.Id
      ];
      System.debug('jobpost::' + jobpost);

      con.Job_Application_Id__c = JobApp.Id;
      con.Job_Name__c = jobpost.Job_Posting__r.Job_Name__c;
      update con;

      base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
      Attachment attach = new Attachment();
      attach.Body = EncodingUtil.base64Decode(base64Data);
      attach.Name = fileName;
      attach.ContentType = contentType;
      attach.ParentID = con.id;
      insert attach;

      // String subjectGmail = 'Thank you for applying';
      String subjectGmail = 'Your application at MV Clouds has been successfully received';

      String bodyGmail = emailtemplate.HtmlValue;
      System.debug('bodyGmail::' + bodyGmail);
      System.debug('con name>>' + con.Name);
      System.debug('con FirstName>>' + con.FirstName);
      System.debug('con LastName>>' + con.LastName);
      bodyGmail = bodyGmail.replace(
        '{!Contact.Name}',
        con.FirstName +
        ' ' +
        con.LastName
      );
      //bodyGmail=bodyGmail.replace('{!Contact.Name}', con.Name);
      bodyGmail = bodyGmail.replace(
        '{!Job_Posting__c.Job_Name__c}',
        jobpost.Job_Posting__r.Job_Name__c
      );
      //String bodyGmail='Dear '+con.FirstName+''+emailtemplate.HtmlValue;
      System.debug('bodyGmail::' + bodyGmail);

      String sendTo = con.FirstName+ ' ' + con.LastName + '<'+ con.Email +'>';

      GoogleGmailApi.sendGmail(subjectGmail,bodyGmail,sendTo);

      String subjectGmailToInfo =
        con.FirstName +
        ' ' +
        con.LastName +
        '- New Application Arrived';
      String subjectBodyGmailToInfo =
        '<p style="font-family:verdana !important;">A new application arrived <br /><br />' +
        'Name:- ' +
        con.FirstName +
        ' ' +
        con.LastName +
        '<br />' +
        'Email:- ' +
        con.Email +
        '<br />' +
        'Mobile:- ' +
        con.MobilePhone +
        '<br />' +
        '<br /><br /></p>' +
        '<a href="https://dharmikmvclouds-developer-edition.ap4.force.com/demo?id=' +
        JobApp.Id +
        '">Click here to schedule the interview Date & Time.</a>';

      String sendToInfo = 'MV Clouds<info@mvclouds.com>';
      GoogleGmailApi.sendGmailWithAttachment(
        subjectGmailToInfo,
        subjectBodyGmailToInfo,
        sendToInfo,
        attach.Id + ''
      );

      return 'true';
    } else {
      if (oldCon[0].Email == Email) {
        return 'email';
      }
      return 'false';
    }
  }
}