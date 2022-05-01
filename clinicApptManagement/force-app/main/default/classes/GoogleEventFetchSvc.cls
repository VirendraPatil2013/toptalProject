public without sharing class GoogleEventFetchSvc {
    public static void fetchEvents(String namedCred,Id PhyId){
        DateTime myDateTime = DateTime.newInstance(System.today(),System.now().time());
        String formatted = myDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        system.debug(formatted);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:'+namedCred+'/calendar/v3/calendars/primary/events?timeMin='+EncodingUtil.urlEncode(formatted,'UTF-8')); 
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('GET');
        req.setTimeout(10000);
        HttpResponse res = h.send(req);
        Map<String,Object> mResponse = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
        List<String> gEventIds = new List<String>();
        response gEvt = new response();
        Map<String,response> mGEvt = new Map<String,response>();
        if(mResponse.containsKey('items')){
            List<Object> items = (List<Object>)mResponse.get('items');
            for(Object itm : items){
                String a = JSON.serialize(itm);
                Map<String,Object> mItm = (Map<String,Object>)JSON.deserializeUntyped(a);
                if(mItm.containsKey('id')){
                    gEvt.evtId = String.ValueOf(mItm.get('id'));
                }
                if(mItm.containsKey('start')){
                    String b = JSON.serialize(mItm.get('start'));
                    Map<String,Object> mStart = (Map<String,Object>)JSON.deserializeUntyped(b);
                    if(mStart.containsKey('dateTime')){
                        String tempDt = String.ValueOf(mStart.get('dateTime'));
                        if(String.isNotBlank(tempDt)){
                            Date sDt = Date.ValueOf(tempDt.subStringBefore('T'));
                            String sTime = String.ValueOf(tempDt.substringAfter('T')).subStringBefore('+');
                            Integer hr = Integer.ValueOf(sTime.subStringBefore(':'));
                            Integer min = Integer.ValueOf(sTime.substringAfter(':').subStringBefore(':'));
                            DateTime startDt = DateTime.newInstance(sDt.year(), sDt.month(), sDt.day(), hr,min, 0);
                            System.debug('startDt'+startDt);
                            gEvt.startDt = startDt;
                        }
                        
                    }
                }
                if(mItm.containsKey('end')){
                    String b = JSON.serialize(mItm.get('end'));
                    Map<String,Object> mEnd = (Map<String,Object>)JSON.deserializeUntyped(b);
                    if(mEnd.containsKey('dateTime')){
                        String tempDt = String.ValueOf(mEnd.get('dateTime'));
                        if(String.isNotBlank(tempDt)){
                            Date sDt = Date.ValueOf(tempDt.subStringBefore('T'));
                            String sTime = String.ValueOf(tempDt.substringAfter('T')).subStringBefore('+');
                            Integer hr = Integer.ValueOf(sTime.subStringBefore(':'));
                            Integer min = Integer.ValueOf(sTime.substringAfter(':').subStringBefore(':'));
                            DateTime endDtime = DateTime.newInstance(sDt.year(), sDt.month(), sDt.day(), hr,min, 0);
                            System.debug('endDtime'+endDtime);
                            gEvt.endDt = endDtime;
                        }
                    }
                }
                if(mItm.containsKey('summary')){
                    gEvt.Summary = String.ValueOf(mItm.get('summary'));
                    System.debug('Summary --> '+gEvt.summary);
                }
                mGEvt.put(gEvt.evtId,gEvt);
            }
            
            if(mGEvt.keySet().size()>0){
                for(Event evt : [SELECT ID,Google_Event_Id__c FROM Event WHERE Google_Event_Id__c IN : mGEvt.keySet()]){
                    if(mGEvt.containsKey(evt.Google_Event_Id__c)){
                        mGEvt.remove(evt.Google_Event_Id__c);
                    }
                }
            }
            if(mGEvt.keySet().size()>0){
                List<Event> events = new List<Event>();
                Id recTypeGCalId = Schema.sObjectType.Event.getRecordTypeInfosByDeveloperName().get('Google_Calendar').getRecordTypeId();
                for(String gEvtId : mGEvt.keySet()){
                    Event evt = new Event();
                    evt.Subject = mGEvt.get(gEvtId).summary;
                    evt.StartDateTime = mGEvt.get(gEvtId).startDt;
                    evt.EndDateTime = mGEvt.get(gEvtId).endDt;
                    evt.Google_Event_Id__c = mGEvt.get(gEvtId).evtId;
                    evt.RecordTypeId=recTypeGCalId;
                    evt.Physician__c = PhyId;
                    events.add(evt);
                }
                if(events.size()>0){
                    insert events;
                }
                
            }
        }
        
    }
    public class response{
        public string summary{get;set;}
        public datetime startDt{get;set;}
        public datetime endDt{get;set;}
        public string evtId{get;set;}
    }
    
}