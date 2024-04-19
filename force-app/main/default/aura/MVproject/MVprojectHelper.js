({
	getProjectsDetails : function(component,event,helper) {
		var action = component.get("c.getProjects");
        action.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){
                var updatedProjects = response.getReturnValue();
                for(var i=0;i<updatedProjects.length;i++){
                    updatedProjects[i].Start_Date__c = (updatedProjects[i].Start_Date__c).substring(8,10);
                }
                component.set("v.projectList",updatedProjects);
            }
        });
        $A.enqueueAction(action);
	}
})