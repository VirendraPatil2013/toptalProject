public without sharing class AppointmentManagerController {
    @AuraEnabled
    public static List<Account> getDepartment(){
        id recTypDeptId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Department').getRecordTypeId();
        List<Account> lstDept = new List<Account>();
        for(Account dept : [SELECT ID,Name,Appointment_Price__c FROM Account WHERE RecordTypeId =:recTypDeptId]){
            lstDept.add(dept);
        }
        return lstDept;
    }
    @AuraEnabled
    public static List<timeSlots> getTimeSlot(String deptId,String timeSlotType,Date aptDt){
        List<timeSlots> lstSlots = new List<timeSlots>();
        Set<Id> phyIds = new Set<Id>();
        List<DateTime> aptDtTm = new List<DateTime>();
        Time currentTime = System.now().time();
        for(Department_Physician__c deptPhy : [SELECT ID,Department__c,Physician__c FROM Department_Physician__c WHERE Department__c =: deptId]){
            phyIds.add(deptPhy.Physician__c);
        }
        
        List<Time_Slot__c> lstTS = [SELECT ID,Time__c,Type__c FROM Time_Slot__c WHERE Department__c=:deptId AND Type__c =: timeSlotType ORDER BY Time__c ASC];
        for(Time_Slot__c ts : lstTS){
            Time tm = ts.Time__c;
            DateTime dt = DateTime.newInstance(aptDt.year(), aptDt.month(), aptDt.day(), tm.hour(), tm.minute(),0);
            if(dt > System.now()){
                aptDtTm.add(dt);
            }
            
        }
        Map<DateTime,Integer> mAptCounter = new Map<DateTime,Integer>();
        for(Event pApt : [SELECT StartDateTime, Id FROM Event WHERE StartDateTime =: aptDtTm AND Physician__c =: phyIds
                                           Order by StartDateTime]){
                                               if(!mAptCounter.containsKey(pApt.StartDateTime)){
                                                   mAptCounter.put(pApt.StartDateTime,0);
                                               }
                                               integer iCount = mAptCounter.get(pApt.StartDateTime);
                                               iCount++;
                                               mAptCounter.put(pApt.StartDateTime,iCount);
                                           }
        
        for(DateTime dt : aptDtTm){
            if(mAptCounter.containsKey(dt)){
                if(mAptCounter.get(dt)>0 && mAptCounter.get(dt) <> phyIds.size()){
                    String temp = dt.format('HH:mm');
                    lstSlots.add(new timeSlots(temp,temp));
                }
            }
            else{
                System.debug('aaaa --> '+dt);
                String temp = dt.format('HH:mm');
                System.debug(dt.timeGmt());
                System.debug('temp --> '+temp);
                lstSlots.add(new timeSlots(temp,temp));
            }
        }
        
        return lstSlots;
    }
    
    public class timeSlots{
        @AuraEnabled
        public string label{get;set;}
        @AuraEnabled
        public string value{get;set;}
        
        public timeSlots(String lbl,String val){
            this.label = lbl;
            this.value=val;
        }
    }
    @AuraEnabled
    public static List<Contact> getAvailablePhysician(String timeSlot,Date ApptDate,String deptId){
        Integer hr = Integer.ValueOf(timeSlot.substringBefore(':'));
        Integer min = Integer.valueof(timeSlot.substringAfter(':'));
        DateTime aptDt = DateTime.newInstance(ApptDate.year(),ApptDate.month(),ApptDate.day(),hr,min,0);
        Id recTypPhyId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Physician').getRecordTypeId();
        Set<Id> phyIds = new Set<Id>();
        for(Department_Physician__c dP : [SELECT ID,Physician__c FROM Department_Physician__c WHERE Department__c =: deptId]){
            phyIds.add(dP.Physician__c);
        }
        
        Map<Id,Contact> mPhysicians = new Map<Id,Contact>([SELECT ID,Name,Title,Description FROM Contact WHERE RecordTypeId =:recTypPhyId AND Id =:phyIds]);
        Map<Id,AggregateResult> aggResult = new Map<Id,AggregateResult>([SELECT Physician__c Id, COUNT(ID) FROM Event WHERE Physician__c = :phyIds AND StartDateTime =:aptDt AND Physician__c =:mPhysicians.keySet()
                                                                         GROUP BY Physician__c HAVING COUNT(ID) > 0]);
        List<Contact> retPhysicians = new List<Contact>();
        for(Id conId : mPhysicians.keySet()){
            if(!aggResult.containsKey(conId)){
                retPhysicians.add(mPhysicians.get(conId));
            }
        }
        
        
        return retPhysicians;
    }
    private static Patient_Appointment__c createAppointmentRecord(String departmentId,DateTime aptDT,String patientId,String physicianId){
        Account dept = [SELECT ID,Appointment_Price__c FROM Account WHERE id =: departmentId];
        Patient_Appointment__c pApt = new Patient_Appointment__c();
        pApt.Department__c = departmentId;
        pApt.Start_Date_Time__c = aptDT;
        pApt.End_Date_Time__c = aptDT.addMinutes(60);
        pApt.Patient__c = patientId;
        pApt.Physician__c = physicianId;
        pApt.Status__c = 'Scheduled';
        pApt.Appointment_Fees__c = dept.Appointment_Price__c;
        try{
            insert pApt;
            
        }
        catch(Exception ex){
            throw new AuraException('Opps ! Something went wrong while creating Appointment record.');
        }
        return pApt;
    }
    @AuraEnabled
    public static String createAppointment(String departmentId,String patientId,String physicianId,Date apptDate,String apptTm){
        //Create Event Record
        Contact patient = [SELECT ID,name,Email,Phone FROM Contact WHERE Id =:patientId LIMIT 1];
        
        DateTime aptDT = generateDateTime(apptDate,apptTm);
        Patient_Appointment__c pApt = createAppointmentRecord(departmentId,aptDT,patientId,physicianId);
        Event evt = new Event();
        evt.Subject = 'Appointment : Patient Name : '+patient.Name;
        evt.StartDateTime = aptDT;
        evt.DurationInMinutes = 30;
        evt.WhatId = departmentId;
        evt.WhoId = patientId;
        evt.Physician__c = physicianId;
        evt.Appointment_Number__c = pApt.Id;
        
        try{
            insert evt;
            createGoogleEvent.createEvent(evt.Id);
        }
        catch(Exception ex){
            throw new AuraException('Opps ! Something went wrong while creating Calendar Invite for Patient.');
        }
        return pApt.Id;
    }
    private static DateTime generateDateTime(Date apptDt,String aaptTm){
        String hrs = aaptTm.substringBefore(':').trim();
        String min = aaptTm.substringAfter(':').trim();
        DateTime dt = DateTime.newInstance(apptDt.year(),apptDt.month(),apptDt.day(),Integer.valueOf(hrs),Integer.ValueOf(min),0);
        return dt;
    }
    @AuraEnabled
    public static string getPatientRecord(String aptId){
        return [SELECT ID,Patient__c FROM Patient_Appointment__c WHERE Id =: aptId LIMIT 1].Patient__c;
    }
}