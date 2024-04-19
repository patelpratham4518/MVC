({
	getEmployeeDetails : function(component,event,secId) {
	  var action = component.get("c.employeeDetails");
      
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                component.set('v.employeeDetailsList',response.getReturnValue());
                var intranetEvt = component.getEvent('intranetBasicEvent');
                intranetEvt.setParams({
                    "employeesList":response.getReturnValue()
                });
                intranetEvt.fire();
            }
        });
        $A.enqueueAction(action);
	},
	
})