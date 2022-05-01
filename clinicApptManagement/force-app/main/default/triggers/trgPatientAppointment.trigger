trigger trgPatientAppointment on Patient_Appointment__c (after update,before update) {
    if(trigger.isAfter){
        PatientAppointmentUtil.executeAfter(trigger.new,trigger.old,trigger.newMap,trigger.oldMap,trigger.OperationType);
    }
    if(trigger.isBefore){
        PatientAppointmentUtil.executeBefore(trigger.new,trigger.old,trigger.newMap,trigger.oldMap,trigger.OperationType);
    }
}