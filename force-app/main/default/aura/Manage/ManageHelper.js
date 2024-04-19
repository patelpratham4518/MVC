({
    scriptsLoaded : function(component, event, helper) {
        console.log('Script loaded..'); 
    },
    
	getProjectList : function(component,event,helper) {
		var action = component.get("c.getProjects");
		action.setCallback(this,function(response){
		    if(response.getState()=="SUCCESS"){
		        console.log(response.getReturnValue());
		        component.set("v.projectList",response.getReturnValue());
		        
		        setTimeout(function(){ 
                    $('#manageProjectListId').DataTable();
                    // add lightning class to search filter field with some bottom margin..  
                    $('div.dataTables_filter input').addClass('slds-input');
                    $('div.dataTables_filter input').css("marginBottom", "10px");
                }, 500); 
		    }
		});
		$A.enqueueAction(action);
	},
	
	getEmployees : function(component,event,helper){
	    var action = component.get("c.employeeDetails");
	    action.setCallback(this,function(response){
	        if(response.getState() == "SUCCESS"){
	            component.set("v.employeeList",response.getReturnValue());
	        }
	    });
	    $A.enqueueAction(action);
	},
	
	getClientList : function(component,event,helper){
	  var action = component.get("c.clientDetails");
	  action.setCallback(this,function(response){
	      if(response.getState()=="SUCCESS"){
	          console.log(response.getReturnValue());
	          component.set("v.clientList",response.getReturnValue());
	      }
	  });
	  $A.enqueueAction(action);
	},
	
	getModuleList : function(component,event,helper){
	   console.log('Manage getModuleList');
	   var action = component.get("c.getAllModules");
	   action.setParams({
	       "projectName" : "none"
	   });
	   action.setCallback(this,function(response){
	       if(response.getState()=="SUCCESS"){
	           console.log(response.getReturnValue());
	           component.set("v.modulelist",response.getReturnValue());
	           
	           setTimeout(function(){ 
                    $('#manageModuleListId').DataTable();
                    // add lightning class to search filter field with some bottom margin..  
                    $('div.dataTables_filter input').addClass('slds-input');
                    $('div.dataTables_filter input').css("marginBottom", "10px");
                }, 500); 
	       }
	   });
	   $A.enqueueAction(action);
	},
	
	getTaskList : function(component,event,helper){
	  var action = component.get("c.getTaskDetails");
	  action.setParams({
	      "isCompleted":false,
	      "allTask":true
	  });
	  action.setCallback(this,function(response){
	      if(response.getState() == "SUCCESS"){
	          component.set("v.taskList",response.getReturnValue());
	          
	          setTimeout(function(){ 
                    $('#manageTaskListId').DataTable();
                    // add lightning class to search filter field with some bottom margin..  
                    $('div.dataTables_filter input').addClass('slds-input');
                    $('div.dataTables_filter input').css("marginBottom", "10px");
                }, 500); 
	      }
	  });
	  $A.enqueueAction(action);
	},
	
	clearClientFieldshelper : function(component,event,helper){
        var clientName = component.find("clientName").set("v.value",'');
        var clientEmail = component.find("clientEmail").set("v.value",'');
        var clientPhone = component.find("clientPhone").set("v.value",'');
        var clientLocation = component.find("clientLocation").set("v.value",'');
        var clientCompany = component.find("clientCompany").set("v.value",'');
        var description = component.find("clientDescription").set("v.value",''); 
	},
	
	assignedProjectHelper : function(component,event,helper){
        component.set("v.message",'');
        component.set("v.assignedEmployeeList",[]);
        var selectedProjectId = '';
        selectedProjectId = event.getSource().get("v.name");
        component.set("v.selectedGlobalproject",selectedProjectId);
        var action = component.get("c.getAssignedEmployeeList");
        action.setParams({
          "projectId" : selectedProjectId
        });
        action.setCallback(this,function(response){
          if(response.getState()=="SUCCESS"){
              var assignedEmps = response.getReturnValue();
              console.log(assignedEmps);
              if(assignedEmps.length>0){
                component.set("v.assignedEmployeeList",assignedEmps);
                component.set("v.showAssignedEmployees",true);
              }else{
                  component.set("v.message",'No Employee Assigned Yet.');
                  component.set("v.showAssignedEmployees",false);                  
              }
              component.set("v.modalpopupAssignedProject",true);
          }
        });
        $A.enqueueAction(action);  
	},
	
	showInfoToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Info Message',
            message: 'Employee is removed Successfully.',
            type: 'info',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    
    showSuccessToast : function(component, event, displayMessage) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message: displayMessage,
            type: 'success',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    
    showErrorToast : function(component, event, displayMessage) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error Message',
            message:displayMessage,
            key: 'info_alt',
            type: 'error',
            mode: 'dismissible'
        });
        toastEvent.fire();
    }
})