@isTest
private class ClinicManagementTestClass {
    @testSetup
    private static void setup(){
        
        List<String> specialization = new List<String>();
        specialization.add('Cardiology');
        specialization.add('Endocrinology');
        specialization.add('Rheumatology');
        specialization.add('General Practice');
        List<Account> accounts = new List<Account>();
        id recTypDeptId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Department').getRecordTypeId();
        for(String spec : specialization){
            accounts.add(new Account(Name = spec,Appointment_Price__c = 100,recordTypeId=recTypDeptId));
        }
        insert accounts;
        
        Contact patient = new Contact();
        patient.LastName = 'Patient';
        patient.FirstName = 'Test';
        patient.Email = 'test@test.com.invalid';
        patient.RecordTypeId = Schema.sObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Patient').getRecordTypeId();
        insert patient;
        
        Contact physician = new Contact();
        physician.LastName = 'Physician';
        physician.FirstName = 'Test';
        physician.Email = 'physician@test.com.invalid';
        physician.AccountId = accounts[0].Id;
        physician.RecordTypeId = Schema.sObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Physician').getRecordTypeId();
        insert physician;
        List<Department_Physician__c> deptPhys = new List<Department_Physician__c>();
        List<Time_Slot__c> timeSlots = new List<Time_Slot__c>();
        for(Account a : accounts){
            Department_Physician__c deptPhy = new Department_Physician__c();
            deptPhy.Physician__c = physician.Id;
            deptPhy.Department__c = a.Id;
            deptPhys.add(deptPhy);
            
            Time_Slot__c ts = new Time_Slot__c();
            ts.Time__c = Time.newInstance(8, 0, 0, 0);
            ts.Type__c = 'Morning';
            ts.Department__c = a.Id;
            
            Time_Slot__c ts1 = new Time_Slot__c();
            ts1.Time__c = Time.newInstance(9, 0, 0, 0);
            ts1.Type__c = 'Morning';
            ts1.Department__c = a.Id;
            timeSlots.add(ts);
            timeSlots.add(ts1);
        }
        insert deptPhys;
        insert timeSlots;
        
    }
    @isTest
    private static void testgetDepartment(){
        List<Account> accs = AppointmentManagerController.getDepartment();
    }
    @isTest
    private static void testcreateAppointment(){
        Account cardio = [SELECT ID FROM Account WHERE Name = 'Cardiology' LIMIT 1];
        Contact patient = [SELECT ID FROM Contact WHERE RecordType.Name='Patient' LIMIT 1];
        Contact physician = [SELECT ID FROM Contact WHERE RecordType.Name='Physician' LIMIT 1];
        Date aptDate = System.today().addDays(1);
        String aptTime = '08:00';
        Test.setMock(HttpCalloutMock.class, new GoogleCreateEventMock());
        Id aptId = AppointmentManagerController.createAppointment(String.ValueOf(cardio.Id), String.ValueOf(patient.Id), String.ValueOf(physician.Id), aptDate, aptTime);
        AppointmentManagerController.getTimeSlot(String.ValueOf(cardio.Id), 'Morning', aptDate);
        AppointmentManagerController.getAvailablePhysician('08:00', aptDate, String.ValueOf(cardio.Id));
        AppointmentManagerController.getPatientRecord(aptId);
        
        
    }
    @isTest
    private static void testgetAvailablePhysician(){
        Account cardio = [SELECT ID FROM Account WHERE Name = 'Cardiology' LIMIT 1];
        Date aptDate = System.today().addDays(1);
        String aptTime = '08:00';
        AppointmentManagerController.getAvailablePhysician(aptTime, aptDate, String.ValueOf(cardio.Id));
    }
    @isTest
    private static void testEventUtil(){
        Account cardio = [SELECT ID FROM Account WHERE Name = 'Cardiology' LIMIT 1];
        Contact patient = [SELECT ID FROM Contact WHERE RecordType.Name='Patient' LIMIT 1];
        Contact physician = [SELECT ID FROM Contact WHERE RecordType.Name='Physician' LIMIT 1];
        
        Patient_Appointment__c pApt = new Patient_Appointment__c();
        pApt.Status__c = 'Scheduled';
        pApt.Patient__c = patient.Id;
        pApt.Physician__c = physician.Id;
        insert pApt;
        Event evt = new Event();
        evt.Subject='Testing...';
        evt.Appointment_Number__c = pApt.Id;
        evt.StartDateTime = System.now();
        evt.DurationInMinutes = 30;
        evt.Google_Event_Id__c = 'ABCD';
        insert evt;
        Test.setMock(HttpCalloutMock.class, new GoogleDeleteEventMock());
        pApt.Status__c = 'Cancelled';
        pApt.Reason_for_Cancelling_Appointment__c = 'Testing...';
        update pApt;
        pApt.Status__c = 'Scheduled';
        try{
        	update pApt;    
        }
        catch(exception ex){
            System.debug(ex.getMessage());
        }
        
    }
    @isTest
    private static void testGoogleEventFetchSvc(){
        Test.startTest();
        Contact physician = [SELECT ID,Unique_Id__c FROM Contact WHERE RecordType.Name='Physician' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new GoogelEventFetchMock());
        fetchGoogleInviteDaily cls = new fetchGoogleInviteDaily(physician.id);
        System.schedule('Testing Job', '0 0 0/1 1/1 * ? *', cls);
        Test.stopTest();
    }
    
}