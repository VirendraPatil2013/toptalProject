public without sharing class deleteGoogleEvent {
    @Future(callout=true)
    public static void deleteEvent(List<String> gEventIds){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:GoogleAPI/calendar/v3/calendars/primary/events/'+gEventIds[0]+'/?sendUpdates=all');
        req.setHeader('content-Type', 'application/json');
        req.setMethod('DELETE');
        req.setTimeout(10000);
        HttpResponse resp = h.send(req);
        System.debug(resp.getBody());
        
    }
}