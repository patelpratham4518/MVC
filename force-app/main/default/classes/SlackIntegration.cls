public without sharing class SlackIntegration {
    @future(callout=true)
    public static void sendSlackMessage(String message, String userSlackId) {
        try {
            String endpoint = 'https://slack.com/api/chat.postMessage';
            String accessTokenOfSlack = System.Label.SlackAccessToken;
            String body = '';
            body += 'token=' + accessTokenOfSlack;
            body += '&channel=' + userSlackId;
            body += '&text=' + message;
            body += '&as_user=true';

            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setHeader('accept', 'application/json');
            req.setBody(body);

            Http http = new Http();
            HTTPResponse response = http.send(req);
            if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                System.debug('Response ==>' + response);
            } else {
                System.debug('Error in request ==>'+ response);
            }
        } catch (Exception e) {
            System.debug('In the catch block of sendSlackMessage ==>');
            System.debug('--Line number ==>' + e.getLineNumber() + '-- Message ==>' + e.getMessage());
            System.debug(e);
        }
    }


    @future(callout=true)
    public static void sendSlackMessagetrainee(String message, String userSlackId) {
        try {
            String endpoint = 'https://slack.com/api/chat.postMessage';
            String accessTokenOfSlack = System.Label.SlackAccessTokenTrainee;
            String body = '';
            body += 'token=' + accessTokenOfSlack;
            body += '&channel=' + userSlackId;
            body += '&text=' + message;
            body += '&as_user=true';

            System.debug('Body'  + body );

            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setHeader('accept', 'application/json');
            req.setBody(body);

            Http http = new Http();
            HTTPResponse response = http.send(req);
            if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                System.debug('Response ==>' + response);
            } else {
                System.debug('Error in request ==>'+ response);
            }
        } catch (Exception e) {
            System.debug('In the catch block of sendSlackMessage ==>');
            System.debug('--Line number ==>' + e.getLineNumber() + '-- Message ==>' + e.getMessage());
            System.debug(e);
        }
    }

}