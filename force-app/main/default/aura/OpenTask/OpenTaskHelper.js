({
	getOpenTaskDetails : function(component,event,helper) {
		var action = component.get("c.getTaskDetails");
		var page=1;
		var recordToDisply=10;
        action.setParams({
            "isCompleted" : false,
            "allTask" : false,
            "pageNumber" : page,
            "recordToDisply": recordToDisply,
        });
        action.setCallback(this,function(response){
            console.log(response.getState());
            if(response.getState()=="SUCCESS"){
                // var openTasks = response.getReturnValue();
                var result=response.getReturnValue();
                //alert(result);
                var openTasks=result.TaskList;
                // alert(openTasks);
                for(var i=0;i<openTasks.length;i++){
                    // alert(openTasks[i].Due_Date__c);
                    openTasks[i].Due_Date__c = (openTasks[i].Due_Date__c).substring(8,10);
                }
                 component.set('v.openTaskList',openTasks);
                
            }
        });
        $A.enqueueAction(action);
	},
})