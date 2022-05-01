public class createGoogleEvent {
    @Future(callout=true)
    public static void createEvent(Id eventId){
        Event evt = [SELECT ID,Description,Subject,WhoId,WhatId,Physician__c,StartDateTime,EndDateTime FROM Event WHERE Id =: eventId LIMIT 1];
        String stDateTime = String.ValueOf(evt.StartDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss'));
        String endDtTime = String.ValueOf(evt.EndDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss'));
        Set<id> conIds = new Set<Id>();
        conIds.add(evt.Physician__c);
        if(evt.WhoId.getSObjectType() == Contact.sObjectType){
            conIds.add(evt.WhoId);
        }
        Map<id,Contact> contacts = new Map<Id,Contact>();
        if(conIds.size()>0){
            contacts = new Map<Id,Contact>([SELECT ID,Name,Email FROM Contact WHERE Id=:conIds]);
        }
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:GoogleAPI/calendar/v3/calendars/primary/events?sendUpdates=all');  
        string bodyRequest = '';
        String bodyRequeste = '{"description":"You have new appointment with Patient : '+contacts.get(evt.WhoId).Name+'","summary":"'+evt.Subject+'","start":{"dateTime":"'+stDateTime+'","timeZone":"Asia/Kolkata"},"end":{"dateTime":"'+endDtTime+'","timeZone":"Asia/Kolkata"},"attendees":[{"email":"'+contacts.get(evt.Physician__c).Email+'"}]}';
        req.setBody(bodyRequeste);    
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        req.setTimeout(10000);
        HttpResponse res = h.send(req);
        System.debug(res.getBody());
        String gEventId = '';
        Map<String,Object> results = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
        for(String tag : results.keySet()){
            if(tag.toUpperCase().trim() == 'ID'){
                gEventId = String.ValueOf(results.get(tag));
            }
        }
        if(String.isNotBlank(gEventId)){
            evt.Google_Event_Id__c = gEventId;
            update evt;
        }
        
    }
   
}