public class callApiMethod {
    public void callMethod(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://www.googleapis.com/auth/calendar.events');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Accept', 'application/json');
        
        // Set the body as a JSON object
        request.setBody('{"end": {"date": "2020-03-02"},"start": {"date": "2020-02-01"},"summary": "abc"}'); 
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug(response.getBody());
        } 
    }
}