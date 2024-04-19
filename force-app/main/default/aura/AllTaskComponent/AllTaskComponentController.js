({
	doInit : function(component, event, helper) {
	    var ShowResultValue = event.getParam("Pass_Result");
	    component.find("projectID").set("v.value",ShowResultValue);
	    var page = component.get("v.page") || 1;
	    component.set("v.setvalue",ShowResultValue);
        var recordToDisply = component.find("recordSize").get("v.value");
		helper.getAlltasks(component,event,helper,page, recordToDisply);
		helper.getModules(component,event,helper);
		helper.getProjects(component,event,helper);
		helper.getEmployees(component,event,helper);
// 		component.set("v.message",'');
	},
	
	waiting: function(component, event, helper) {
	    
        component.set("v.HideSpinner", true);
    },
    
    doneWaiting: function(component, event, helper) {
        component.set("v.HideSpinner", false);
    },
    searchTasksList: function(component, event, helper) {
        var ShowResultValue='';
      var page = 1
      var recordToDisply = component.find("recordSize").get("v.value");
      helper.getAlltasks(component,event,helper,page, recordToDisply);
    },
    navigate: function(component, event, helper) {
      var ShowResultValue='';
      var page = component.get("v.page") || 1;
      var direction = event.getSource().get("v.label");
      var recordToDisply = component.find("recordSize").get("v.value");
      page = direction === "Previous" ? (page - 1) : (page + 1);
      helper.getAlltasks(component,event,helper,page, recordToDisply);
 
    },
    onSelectChange: function(component, event, helper) {	 
        var ShowResultValue='';
      var page = 1
      var recordToDisply = component.find("recordSize").get("v.value");
      helper.getAlltasks(component,event,helper, page, recordToDisply);
    },
    // searchTasksList : function(component,event,helper){
    //     var selectedModule = component.find('moduleID').get("v.value");
    //     var selectedProject = component.find('projectID').get("v.value");
    //     var selectedEmp = component.find("employeeID").get("v.value");
    //     // component.set("v.message",'');
    //     var action = component.get("c.searchTasks");
    //     action.setParams({
    //         "module" : selectedModule,
    //         "project" : selectedProject,
    //         "emp" : selectedEmp
            
    //     });
        
    //     action.setCallback(this,function(response){
    //         if(response.getState() == "SUCCESS"){
    //             component.set("v.taskList",[]);
    //             var returnedTasks = response.getReturnValue();
    //             if(returnedTasks.length >0 ){
    //                 component.set("v.noRecords" , true);
    //                 component.set("v.taskList",response.getReturnValue());
    //             }else{
    //                 component.set("v.message",'No result found');
    //                 component.set("v.noRecords" , false);
    //             }
                
    //         }
    //     });
    //     $A.enqueueAction(action);
    // }	
})