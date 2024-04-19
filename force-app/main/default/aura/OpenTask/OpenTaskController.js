({
	doInit : function(component, event, helper) {
        console.log('Controller open');
		helper.getOpenTaskDetails(component,event,helper);
	},
	
	taskCompleteDetails : function(component,event,helper){
	    component.set('v.selectedTaskDetails',[]);
	    var taskId = event.getSource().get("v.value");
	    var action = component.get("c.getFullTaskDetail");
	    action.setParams({
	        "recordId":taskId,
	    });
	    action.setCallback(this,function(response){
	        if(response.getState() == "SUCCESS"){
	            component.set('v.selectedTaskDetails',response.getReturnValue());
	            component.set("v.modalpopupTaskDetails", true);
	        } 
	    });
	    $A.enqueueAction(action);
	},
	closeModel: function(component, event, helper) {
      component.set("v.modalpopupTaskDetails", false);
   },
})