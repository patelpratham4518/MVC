({
	getProjectsDetails : function(component,event,helper) {
		var action = component.get("c.getProjects");
        action.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){
                var updatedProjects = response.getReturnValue();
                component.set("v.projectList",updatedProjects);
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
	        }
	    });
	    $A.enqueueAction(action);
	},
	
	getTimeSheet : function(component,page,recordToDisply){
	    console.log('inside helper Timesheet');
	    var action = component.get("c.getTimeSheetList");
	    var selectedModule = component.find('moduleID').get("v.value");
        var selectedProject = component.find('projectID').get("v.value");
        var selectedEmp = component.find("employeeID").get("v.value");

	    if(selectedModule==null) selectedModule='';
	    if(selectedProject==null) selectedProject='';
	    if(selectedEmp==null) selectedEmp='';
 	    action.setParams({
	       "module" : selectedModule,
            "project" : selectedProject,
            "emp" : selectedEmp,
             "pageNumber": page,
             "recordToDisply": recordToDisply
        });
	    action.setCallback(this,function(response){
	        if(response.getState()=="SUCCESS"){
	            var result = response.getReturnValue();
	            console.log('before');
	            console.log(result.timeSheetList);
	            console.log('After');
	            //alert(result.timeSheetList.Category__c);
	            component.set("v.timeSheetList",result.timeSheetList);
                component.set("v.page", result.page);
                component.set("v.total", result.total);
                component.set("v.pages", Math.ceil(result.total / recordToDisply));
                if(Math.ceil(result.total)>0 ){
                    component.set("v.noRecords" , false);
                    //component.set("v.timeSheetList",returnedTasks);
                }else{
                    component.set("v.message",'No result found');
                    component.set("v.noRecords" , true);
                    component.set("v.pages" ,1);
                }
	        }
	    });
	    $A.enqueueAction(action);
	},
	
    fetchPickListVal: function(component, event, helper) {
        console.log('inside helper picklist');
        var action = component.get("c.getselectOptions");
        action.setParams({
            "objObject": "Time_Sheet__c",
            "fld": Category__c
        });
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                console.log('option success');
                if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: ""
                    });
                }
                for (var i = 0; i < allValues.length; i++) {
                    opts.push({
                        class: "optionClass",
                        label: allValues[i],
                        value: allValues[i]
                    });
                }
                console.log(opts);
                component.find("categorySelectListId").set("v.options", opts);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCredentials : function(component,event,helper){
      var action = component.get("c.credentialList");  
      action.setCallback(this,function(response){
          if(response.getState()=="SUCCESS"){
              console.log('credentials');
              console.log(response.getReturnValue());
              component.set("v.credentials",response.getReturnValue());
          }
      });
      $A.enqueueAction(action);
    },

// 	searchTimeSheetHelper : function(component,event, helper,page,recordToDisply){
// 	    alert(page);
// 	    alert(recordToDisply);
// 	    var selectedModule = component.find('moduleID').get("v.value");
//         var selectedProject = component.find('projectID').get("v.value");
//         var selectedEmp = component.find("employeeID").get("v.value");
//         // component.set("v.message",'');
//         var action = component.get("c.searchTimeSheet");
//         action.setParams({
//             "module" : selectedModule,
//             "project" : selectedProject,
//             "emp" : selectedEmp,
            
            
//         });
        
//         action.setCallback(this,function(response){
//             if(response.getState() == "SUCCESS"){
//                 console.log('Success search');
//                 component.set("v.timeSheetList",[]);
//                 var returnedTasks = response.getReturnValue();
//                 if(returnedTasks.length >0 ){
//                     component.set("v.noRecords" , true);
//                     component.set("v.timeSheetList",returnedTasks);
//                 }else{
//                     component.set("v.message",'No result found');
//                     component.set("v.noRecords" , false);
//                 }
                
//             }
//         });
//         $A.enqueueAction(action);
// 	},
	 
	errorAlertToast :function(component,event,displayMessage){
	    var toastEvent = $A.get("e.force:showToast");
        // alert(toastEvent);
        toastEvent.setParams({
            title : 'Error Message',
            message: displayMessage,
            key: 'info_alt',
            type: 'error',
            mode: 'dismissible'
        });
        toastEvent.fire();
	},
	
	successAlertToast : function(component,event,recordToDisply){
	    var toastEvent = $A.get("e.force:showToast");
        // alert(toastEvent);
        toastEvent.setParams({
            title : 'Success Message',
            message: recordToDisply,
            key: 'info_alt',
            type: 'success',
            mode: 'dismissible'
        });
        toastEvent.fire();
        //$A.get('e.force:refreshView').fire();
	},
	
	saveTimeSheetDetails : function(component,event,helper){
	    this.successAlertToast(component,event,helper);
	}
	    
})