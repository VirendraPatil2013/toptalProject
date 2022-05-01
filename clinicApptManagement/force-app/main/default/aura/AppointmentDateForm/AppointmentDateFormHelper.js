({
    getTimeSlot: function(component,event){
        var action = component.get("c.getTimeSlot");
        var deptId = component.get("v.selDepartmentId");
        var timeSlotType = component.get("v.timeSlotType");
        var aptDt = component.get("v.aptDate");
        action.setParams({
            "deptId":deptId,
            "timeSlotType":timeSlotType,
            "aptDt":aptDt
        });
        action.setCallback(this,function(resp){
            if(resp.getState() == "SUCCESS"){
                component.set("v.timeSlots",resp.getReturnValue());
                console.log(resp.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    getPhysicians : function(component,event,changeVal) {
        var aptDt = component.get("v.aptDate");
        var action = component.get("c.getAvailablePhysician");
        var deptId = component.get("v.selDepartmentId");
        action.setParams({
            "timeSlot" : changeVal,
            "ApptDate":aptDt,
            "deptId":deptId
        });
        action.setCallback(this,function(resp){
            if(resp.getState() == "SUCCESS"){
                component.set("v.physicians",resp.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    navigateToRecord:function(newAptId){
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": newAptId,
            "slideDevName": "detail"
        });
        navEvt.fire();
        
    }
})