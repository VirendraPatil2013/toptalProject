({
	doInit : function(component, event, helper) {
        var action = component.get("c.getPatientRecord");
        var recId = component.get("v.recordId");
        action.setParams({
            "aptId":recId
        });
        action.setCallback(this,function(resp){
            if(resp.getState() == "SUCCESS"){
                component.set("v.patientId", resp.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	}
})