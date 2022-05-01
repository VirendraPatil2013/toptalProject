@isTest
global class GoogelEventFetchMock implements HttpCalloutMock{
	global HttpResponse respond(HttpRequest request){
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type', 'application/json');
        resp.setBody('{"items":[{"id":"123112","start":{"dateTime":"2022-05-01T09:00:00+05:30"},"end":{"dateTime":"2022-05-01T09:30:00+05:30"},"summary":"Appointment"}]}');
        resp.setStatusCode(200);
        return resp;
    }
}