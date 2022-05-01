({
    doInit:function(component,event,helper){
        var action = component.get("c.getDepartment");
        action.setCallback(this,function(resp){
            console.log(resp.getReturnValue());
            if(resp.getState()=="SUCCESS"){
                component.set("v.options",resp.getReturnValue());
                console.log('+'+resp.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    onChangeEvent : function(component, event, helper) {
        var action = component.get("c.getTimeSlot");
        helper.getTimeSlot(component,event);
        
        var timeSlot = component.get("v.selectedTimeSlot");
        if(timeSlot != null && timeSlot !="" && timeSlot != " ")
            helper.getPhysicians(component,event,timeSlot);
        
        
    },
    onSlotSelection: function(component,event,helper){
        var changeVal = event.getParam("value");
        helper.getPhysicians(component,event,changeVal);
    },
    handleBookAppt : function(component,event,helper){
        var physicianId = event.getParam("physicianId");
        var deptId = component.get("v.selDepartmentId");
        var patientId = component.get("v.recordId");
        if(patientId == null || patientId =="" || patientId == " "){
            patientId = component.get("v.patientId");
        }
        var action =component.get("c.createAppointment");
        var aptDt = component.get("v.aptDate");
        var selTimeSlot = component.get("v.selectedTimeSlot");
        action.setParams({
            "departmentId": deptId,
            "patientId":patientId,
            "physicianId":physicianId,
            "apptDate": aptDt,
            "apptTm":selTimeSlot
        });
        action.setCallback(this,function(resp){
            console.log(resp.getState());
            if(resp.getState() == "SUCCESS"){
                var newAptId = resp.getReturnValue();
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Success !",
                    "type":"success",
                    "message": "Appointment Booked Successfully."
                });
                resultsToast.fire();
                helper.navigateToRecord(newAptId);
                
            }
            else if(resp.getState() == "ERROR"){
                var errors = action.getError();
                console.log(errors);
            }
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        });
        $A.enqueueAction(action);
    },
    onDepartmentChg: function(component,event,helper){
        var selectedVal = component.get("v.selDepartmentId");
        var a = component.get("v.options");
        component.set("v.timeSlots",[]);
        component.set("v.physicians",[]);
        for(var i=0;i<a.length;i++){
            if(a[i].Id == selectedVal){
                component.set("v.bookingPrice",a[i].Appointment_Price__c);
               break;
            }
        }
        
    },
    onchangeslotType:function(component,event,helper){
        var type = event.getSource().get("v.name");
        component.set("v.timeSlotType",type);
        helper.getTimeSlot(component,event);
        
    }
})