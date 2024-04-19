({
	getHolidaysDetails : function(component,event,helper) {
		var action = component.get("c.holidayDetails");
        
        action.setCallback(this,function(response){
            if(response.getState() == 'SUCCESS'){
                var updatedHolidaysList = response.getReturnValue();
                //alert(updatedHolidaysList.name);
                for(var i=0;i<updatedHolidaysList.length;i++){
                    updatedHolidaysList[i].Date__c =(updatedHolidaysList[i].Date__c).substring(8,10);
                }
                component.set('v.holidaysList',updatedHolidaysList);
            }
        });
        $A.enqueueAction(action);
	}
})