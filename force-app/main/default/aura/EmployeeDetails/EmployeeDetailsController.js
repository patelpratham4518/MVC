({
    doInit : function(component, event, helper) {
       console.log('controller');
       helper.getEmployeeDetails(component,event,helper);
    },
    waiting: function(component, event, helper) {
	    
        component.set("v.HideSpinner", true);
    },
    
    doneWaiting: function(component, event, helper) {
        component.set("v.HideSpinner", false);
    },
    employeeCompleteDetails : function(component,event,helper){
        component.set("v.employeeFullDetails",[]);
        var empId = event.getSource().get("v.value");
        var action = component.get("c.employeeFullDetails");
        console.log(empId);
        action.setParams({
            "recordId" : empId 
        });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                component.set("v.employeeFullDetails",response.getReturnValue());
                console.log(response.getReturnValue());
                component.set("v.employeeCompleteDetailsModal",true);
            }
        });
        $A.enqueueAction(action);
    },
    closeModel: function(component, event, helper) {
      component.set("v.employeeCompleteDetailsModal", false);
   },
})