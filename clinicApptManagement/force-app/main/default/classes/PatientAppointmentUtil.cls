public without sharing class PatientAppointmentUtil {
    public static void executeAfter(List<Patient_Appointment__c> newList,List<Patient_Appointment__c> oldList,Map<Id,Patient_Appointment__c> newMap,Map<Id,Patient_Appointment__c> oldMap,System.TriggerOperation op){
        Set<Id> aptIds = new Set<Id>();
        
        for(Patient_Appointment__c pApt : newList){
            if(op == System.TriggerOperation.AFTER_UPDATE){
                if(pApt.Status__c != oldMap.get(pApt.Id).Status__c){
                    if(pApt.Status__c == 'Cancelled'){
                        aptIds.add(pApt.Id);
                    }
                }
            }
        }
        if(aptIds.size()>0){
            eventUtil.cancelEvent(aptIds);
        }
    }
    public static void executeBefore(List<Patient_Appointment__c> newList,List<Patient_Appointment__c> oldList,Map<Id,Patient_Appointment__c> newMap,Map<Id,Patient_Appointment__c> oldMap,System.TriggerOperation op){
        for(Patient_Appointment__c pApt : newList){
            if(oldMap.get(pApt.Id).Status__c == 'Cancelled'){
                pApt.addError('Appointment is not editable when status is Cancelled.');
            }
            
        }
    }
}