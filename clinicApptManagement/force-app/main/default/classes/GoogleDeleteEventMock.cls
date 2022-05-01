@isTest
global class GoogleDeleteEventMock implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest request){
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type', 'application/json');
        resp.setStatusCode(200);
        return resp;
    }
    
}