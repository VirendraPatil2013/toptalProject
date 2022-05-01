public without sharing class eventUtil {
    public static void cancelEvent(Set<Id> aptIds){
        List<Event> evts = [SELECT ID FROM Event WHERE Appointment_Number__c = : aptIds];
        try{
            if(evts.size()>0){
                delete evts;
            }
        }
            catch(Exception ex){
                for(sObject obj : trigger.new){
                    obj.addError('Error Occured while cancelling Appointment. Please reach out to System administrator.');
                }
            }
        }
    public static void executeAfter(List<Event> newList,List<Event> oldList, Map<Id,Event> newMap,Map<Id,Event> oldMap,System.TriggerOperation op){
        if(op == System.TriggerOperation.AFTER_DELETE){
            List<String> gEvtIds = new List<String>();
            for(Event evt : oldList){
                if(String.IsNotBlank(evt.Google_Event_Id__c)){
                    if(!gEvtIds.contains(evt.Google_Event_Id__c)){
                        gEvtIds.add(evt.Google_Event_Id__c);
                    }
                }
            }
            if(gEvtIds.size()>0){
                deleteGoogleEvent.deleteEvent(gEvtIds);
            }
        }
    }
    
}