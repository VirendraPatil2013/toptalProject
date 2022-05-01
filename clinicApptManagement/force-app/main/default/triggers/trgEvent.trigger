trigger trgEvent on Event (after delete) {
    if(trigger.isAfter){
        eventUtil.executeAfter(trigger.new,trigger.old,trigger.newMap,trigger.oldMap,trigger.OperationType);
    }
    
}