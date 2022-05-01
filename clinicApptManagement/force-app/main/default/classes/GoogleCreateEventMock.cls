@isTest
global class GoogleCreateEventMock implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest request){
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type', 'application/json');
        resp.setBody('{"id":"12345432"}');
        resp.setStatusCode(200);
        return resp;
    }

}