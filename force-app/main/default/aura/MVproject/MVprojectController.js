({
	doInit : function(component, event, helper) {
        helper.getProjectsDetails(component,event,helper);		
	},
	
	projectCompleteDetails : function(component,event,helper){
	    component.set("v.projectCompleteDetail",[]);
	    component.set("v.modulesList",[]);
	    var projectId = event.getSource().get("v.value");
	    var action = component.get("c.getFullProjectDetail");
        action.setParams({
            "recordId":projectId
        });
        action.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){
                component.set("v.projectCompleteDetail",response.getReturnValue());
                console.log(response.getReturnValue());
                var modulesListRelatedToProject = response.getReturnValue();
                component.set("v.modulesList",modulesListRelatedToProject[0].Modules__r);
                component.set("v.modalpopupProjectDetails",true);
            }
        });
        $A.enqueueAction(action);
	},
	closeModel: function(component, event, helper) {
      component.set("v.modalpopupProjectDetails", false);
   }
})