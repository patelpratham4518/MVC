({
	getCompletedTaskDetails : function(component,event,helper) {
		var action = component.get("c.getTaskDetails");
        action.setParams({
            "isCompleted" : true,
            "allTask" : false
        });
        action.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){
                // var completedTasks = response.getReturnValue();
                var result=response.getReturnValue();
                var completedTasks=result.TaskList;
                for(var i=0;i<completedTasks.length;i++){
                    completedTasks[i].Due_Date__c = (completedTasks[i].Due_Date__c).substring(8,10);
                }
                component.set('v.recentTaskList',completedTasks);
            }
        });
        $A.enqueueAction(action);
	},
})