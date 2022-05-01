({
	bookAppointment : function(component, event, helper) {
        var physicianId = event.getSource().get("v.name");
		var compEvent = component.getEvent("bookApptEvent");
        console.log(physicianId);
        compEvent.setParams({
            "physicianId": physicianId
        });
        compEvent.fire();
        console.log('Component event fired...');
	}
})