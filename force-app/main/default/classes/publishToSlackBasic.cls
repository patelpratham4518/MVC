public class publishToSlackBasic {
  public class slackRequest {
    // @InvocableVariable(label='Slack Message' required=true)
    // public String slackMessage;
    // @InvocableVariable(label='Slack Message' required=true)
    // public String Apexvar;
    @InvocableVariable(label='Channel/User to post to' required=true)
    public String channel;
  }

  @InvocableMethod(label='Publish to Slack')
  public static void publishToSlack(List<slackRequest> requests) {
    System.debug('Start Flow');
    String webhookURL = 'https://hooks.slack.com/services/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'; //Naimish url
    String webhookURL2 = 'https://hooks.slack.com/services/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'; //Karan url
    // String webhookURL3 = 'https://hooks.slack.com/services/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';             //dharmik url
    //String webhookURL4 = 'https://hooks.slack.com/services/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'; //mv team url
    String webhookURL4 = 'https://hooks.slack.com/services/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'; //mv team url

    List<Interview__c> intlist = [
      SELECT
        Id, Date__c, Time__c, Contact__r.NAme, Meeting_Link__c, Interview_Round_Name__c, Job_Application__r.Job_Posting__c, Interview_DateTime__c, Interviewer__r.Slack_Id__c, Result__c, Job_Application__r.Job_Posting__r.Job_Name__c, Interviewer__r.Name
      FROM Interview__c
      WHERE Date__c = TODAY AND Result__c = ''
      ORDER BY Time__c
    ];
    List<String> strlst = new List<String>();
    String greeting =
      'Good Morning MV Team ! \n\n ' + 'Today\'s Interviewes :-  \n';
    strlst.add(greeting);
	String slackMessage;
    for (Interview__c intr : intlist) {
      if (intr.Meeting_Link__c == true) {
        DateTime dt = intr.Interview_DateTime__c;
        String dtStr = dt.format('hh:mm a');

        // String slackMessage = intr.Contact__r.Name + ' - ' + intr.Interviewer__r.Slack_Id__c + ' - '+ dtStr + ' - ' +  intr.Interview_Round_Name__c + ' Round' + ' (Online)';
        // <https://dharmikmv-dev-ed.lightning.force.com/lightning/r/Interview__c/ + intr.Contact__r.Id + /view |intr.Contact__r.Name>

         slackMessage =
          '<https://dharmikmv-dev-ed.lightning.force.com/lightning/r/Contact/' +
          intr.Contact__r.Id +
          '/view |' +
          intr.Contact__r.Name +
          '> ' +
          ' - ' +
          intr.Interviewer__r.Slack_Id__c +
          ' - ' +
          dtStr +
          ' - ' +
          intr.Interview_Round_Name__c +
          ' Round' +
          ' (Online)' +
          ' - ' +
          intr.Job_Application__r.Job_Posting__r.Job_Name__c;

        // String slackMessage ='<a href="'+System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/Interview__c/'+intr.Contact__r.Id+'/view">'+intr.Contact__r.Name+'</a>'
        //                     + ' - ' + intr.Interviewer__r.Slack_Id__c + ' - '+ dtStr + ' - ' +  intr.Interview_Round_Name__c + ' Round' + ' (Online)';

        System.debug('slackMessage==>' + slackMessage);
        strlst.add(slackMessage);
      } else {
        DateTime dt = intr.Interview_DateTime__c;
        String dtStr = dt.format('hh:mm a');

         slackMessage =
          '<https://dharmikmv-dev-ed.lightning.force.com/lightning/r/Contact/' +
          intr.Contact__r.Id +
          '/view |' +
          intr.Contact__r.Name +
          '> ' +
          ' - ' +
          intr.Interviewer__r.Slack_Id__c +
          ' - ' +
          dtStr +
          ' - ' +
          intr.Interview_Round_Name__c +
          ' Round' +
          ' (Offline)' +
          ' - ' +
          intr.Job_Application__r.Job_Posting__r.Job_Name__c;

        System.debug('slackMessage==>' + slackMessage);
        strlst.add(slackMessage);
      }
    }
    String sssss = '';
    // if (sssss != null && sssss != '') {
    for (String str : strlst) {
      sssss += str + '\n';
    }
    // }
    // for (String str : strlst) {
    //     sssss += str +'\n';
    // }
      if (String.isNotBlank(slackMessage)) {
        
    for (slackRequest r : requests) {
      JSONGenerator gen = JSON.createGenerator(true);
      gen.writeStartObject(); //Inserts {
      gen.writeStringField('text', sssss);
      // gen.writeListField('list', strlst);
      // gen.writeStringField('text', r.Apexvar);
      gen.writeStringField('channel', r.channel);
      gen.writeStringField('username', 'Salesforce Bot');
      gen.writeStringField('icon_emoji', ':monkey_face:');
      gen.writeEndObject(); //Inserts }

      String body = gen.getAsString(); //Translates JSONGenerator to string to be passed to callout
      System.debug(body);
      System.enqueueJob(new qCallOut(webhookURL, 'POST', body));
      System.enqueueJob(new qCallOut(webhookURL2, 'POST', body));
      // System.enqueueJob(new qCallOut(webhookURL3, 'POST', body));
      System.enqueueJob(new qCallOut(webhookURL4, 'POST', body));
    }
  }
      }


  public class qCallOut implements System.Queueable, Database.AllowsCallouts {
    private final String url;
    private final String method;
    private final String body;

    public qCallOut(String url, String method, String body) {
      this.url = url;
      this.method = method;
      this.body = body;
    }

    public void execute(System.QueueableContext ctx) {
      HttpRequest req = new HttpRequest();
      req.setEndpoint(url);
      req.setMethod(method);
      req.setBody(body);
      Http http = new Http();
      HttpResponse res = http.send(req);
    }
  }
}