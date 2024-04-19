({
	getAlltasks : function(component,event,helper,page,recordToDisply) {
	    //alert(recordToDisply); 
	    //alert(page);
		var action = component.get("c.getTaskDetails");
		var selectedModule = component.find('moduleID').get("v.value");
        var selectedProject = component.find('projectID').get("v.value");
        var selectedEmp = component.find("employeeID").get("v.value");
        
        if(selectedModule==null) selectedModule='';
	    if(selectedProject==null) selectedProject='';
	    if(selectedEmp==null) selectedEmp='';
		action.setParams({
		    "isCompleted":false,
		    "allTask" : true,
		    "pageNumber" : page,
		    "recordToDisply": recordToDisply,
		    "module" : selectedModule,
            "project" : selectedProject,
            "emp" : selectedEmp
		});
		
		action.setCallback(this,function(response){
		    if(response.getState()=="SUCCESS"){
		        var result=response.getReturnValue();
		        component.set("v.taskList",result.TaskList);
		        component.set("v.timeSheetList",result.timeSheetList);
                component.set("v.page", result.page);
                component.set("v.total", result.total);
                //alert(result.total);
                component.set("v.pages", Math.ceil(result.total / recordToDisply));
		        console.log(response.getReturnValue());
		    }
		});
		$A.enqueueAction(action);
	},
	
	getModules : function(component,event,helper){
	    var action = component.get("c.getAllModules");
	    action.setParams({
	        "projectName":"none"
	    });
	    action.setCallback(this,function(response){
	        if(response.getState() == "SUCCESS"){
	            component.set("v.moduleList",response.getReturnValue());
	            console.log(response.getReturnValue());
	        }
	    });
	    $A.enqueueAction(action);
	},
	
	getProjects : function(component,event,helper){
	    console.log('getAllProjects');
	    var action = component.get("c.getAllProjects");
	    action.setCallback(this,function(response){
	        if(response.getState() == "SUCCESS"){
	            component.set("v.projectList",response.getReturnValue());
	            console.log(response.getReturnValue());
	        }
	    });
	    $A.enqueueAction(action);
	},
	
	getEmployees : function(component,event,helper){
	    console.log('getEmployees');
	    var action = component.get("c.employeeDetails");
	    action.setCallback(this,function(response){
	        if(response.getState() == "SUCCESS"){
	            component.set("v.employeeList",response.getReturnValue());
	            console.log(response.getReturnValue());
	        }
	    });
	    $A.enqueueAction(action);
	}
})