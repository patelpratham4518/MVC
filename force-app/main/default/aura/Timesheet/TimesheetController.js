({
	doInit : function(component, event, helper) {
	    var ShowResultValue = event.getParam("Pass_Result");
	    component.find("projectID").set("v.value",ShowResultValue);
	    component.set("v.selectedVal", ShowResultValue);
	   // helper.fetchPickListVal(component,event,helper);
		helper.getProjectsDetails(component,event,helper);
		var page = component.get("v.page") || 1;
        var recordToDisply = component.find("recordSize").get("v.value");
        helper.getTimeSheet(component, page, recordToDisply);
		helper.getModules(component,event,helper);
		helper.getEmployees(component,event,helper);
		helper.getCredentials(component,event,helper);
	},
	
    waiting: function(component, event, helper) {
	    
        component.set("v.HideSpinner", true);
    },
    
    doneWaiting: function(component, event, helper) {
        component.set("v.HideSpinner", false);
    },
	
	navigate: function(component, event, helper) {
      var page = component.get("v.page") || 1;
      var direction = event.getSource().get("v.label");
      var recordToDisply = component.find("recordSize").get("v.value");
      page = direction === "Previous" ? (page - 1) : (page + 1);
      helper.getTimeSheet(component, page, recordToDisply);
 
    },
 
    onSelectChange: function(component, event, helper) {	 
      var page = 1
      var recordToDisply = component.find("recordSize").get("v.value");
      helper.getTimeSheet(component, page, recordToDisply);
    },
    
    navigateSearch: function(component, event, helper) {
      var page = component.get("v.page") || 1;
      var direction = event.getSource().get("v.label");
      var recordToDisply = component.find("recordSize").get("v.value");
      page = direction === "Previous" ? (page - 1) : (page + 1);
      helper.searchTimeSheetHelper(component, page, recordToDisply);
 
    },
 
    onSelectChangeSearch: function(component, event, helper) {	 
      var page = 1
      var recordToDisply = component.find("recordSize").get("v.value");
      helper.searchTimeSheetHelper(component, page, recordToDisply);
    },
	
	projectSelectListFunction : function(component,event,helper){
	    component.set("v.taskList",[]);
    	component.find('taskSelectId').set("v.disabled",true);
    	var statusID = component.find('statusCheckboxId');
    	$A.util.addClass(statusID,'slds-hide');
	    var selectedProjected = event.getSource().get("v.value");
	    if(selectedProjected != ''){
	        var action = component.get("c.getAllModules");
	        action.setParams({
	            "projectName" : selectedProjected
	        });
	        action.setCallback(this,function(response){
	            if(response.getState()=="SUCCESS"){
	                var relatedModules = response.getReturnValue();
	                if(relatedModules.length > 0){
                        component.set("v.moduleList",response.getReturnValue());	                    
	                    component.find("moduleSelectListId").set("v.disabled",false);
	                }else{
	                    component.set("v.moduleList",[]);
	                    component.set("v.taskList",[]);
                        component.find("moduleSelectListId").set("v.disabled",true);
                        component.find('taskSelectId').set("v.disabled",true);
                        component.find("moduleSelectListId").set("v.value",'');
                        component.find("taskSelectId").set("v.value",'');
	                }
	            }
	        });
	        $A.enqueueAction(action);
	    }else{
	        component.set("v.moduleList",[]);
	        component.set("v.taskList",[]);
            component.find("moduleSelectListId").set("v.disabled",true);
            component.find('taskSelectId').set("v.disabled",true);
            component.find("moduleSelectListId").set("v.value",'');
            component.find("taskSelectId").set("v.value",'');
	    }
	},
	
	moduleSelectListFunction : function(component,event,helper){
	    var selectedProject = component.find('projectSelectListId').get('v.value');
	    var selectedModule = component.find('moduleSelectListId').get('v.value');
	    var statusID = component.find('statusCheckboxId');
	    $A.util.addClass(statusID,'slds-hide');
	    if(selectedProject != '' && selectedModule != ''){
	        var action = component.get("c.getTaskRelatedToModule");
    	    action.setParams({
    	        "projectName": selectedProject,
    	        "moduleName" : selectedModule
    	    });
    	    action.setCallback(this,function(response){
    	        if(response.getState()=="SUCCESS"){
    	            var relatedTasks = response.getReturnValue();
    	            if(relatedTasks.length>0){
    	                component.set("v.taskList",relatedTasks);
    	                component.find('taskSelectId').set("v.disabled",false)
    	            }else{
    	                component.set("v.taskList",[]);
    	                component.find('taskSelectId').set("v.disabled",true);
    	                component.find("taskSelectId").set("v.value",'');
    	            }
    	           // component.set("v.taskList",relatedTasks);
    	        }
    	    });
    	    $A.enqueueAction(action);
	    }else{
	        component.set("v.taskList",[]);
    	    component.find('taskSelectId').set("v.disabled",true);
            component.find("taskSelectId").set("v.value",'');	        
	    }
	},
	
	taskSelectListFunction : function(component,event,helper){
	    var selectedTask = component.find('taskSelectId').get('v.value');
	    var statusID = component.find('statusCheckboxId');
	    if(selectedTask != ''){
	        $A.util.removeClass(statusID,'slds-hide');
	    }else{
	        $A.util.addClass(statusID,'slds-hide');
	    }
	},
	
	showTimesheet : function(component,event,helper){
	   var tableID = component.find("timesheettableId");
	   var timeSheetID = component.find('timesheetCalenderId');
	   
	   $A.util.addClass(tableID,"hideTimeSheet");
	   $A.util.removeClass(timeSheetID,"hideTimeSheet");
	},
	
	showTimeSheetTable : function(component,event,helper){
	   component.find("categorySelectListId").set("v.value",'');
	   component.find("projectSelectListId").set("v.value",'');
	   component.find("moduleSelectListId").set("v.value",'');
	   component.find("taskSelectId").set("v.value",'');
       component.find("statusCheckboxId").set("v.checked",false);
	   component.find("selectedDateId").set("v.value",'');
	   component.find("selectedHoursId").set("v.value",'00');
	   component.find("selectedMinutesId").set("v.value",'00');
	   component.find("descriptionId").set("v.value",'');
	   var tableID = component.find("timesheettableId");
	   var timeSheetID = component.find('timesheetCalenderId');
	   
	   $A.util.removeClass(tableID,"hideTimeSheet");
	   $A.util.addClass(timeSheetID,"hideTimeSheet");
	},
	
	jsControllerToSaveTimeSheetDetails : function(component,event,helper){
	    var btnEvent = event.getSource().get("v.label");
	    var tableID = component.find("timesheettableId");
	    var timeSheetID = component.find('timesheetCalenderId');
	    var displayMessage = '';
	    var selectedCategory = component.find("categorySelectListId").get("v.value");
	    var selectedProject = component.find("projectSelectListId").get("v.value");
	    var selectedModule = component.find("moduleSelectListId").get("v.value");
	    var selectedtask = component.find("taskSelectId").get("v.value");
	    var isCompleted = component.find("statusCheckboxId").get("v.checked");
	    var selectedDate = component.find("selectedDateId").get("v.value");
	    var selectedHours = component.find("selectedHoursId").get("v.value");
	    var selectedMinutes = component.find("selectedMinutesId").get("v.value");
	    var description = component.find("descriptionId").get("v.value");
	    console.log(isCompleted);
	    if(selectedCategory == ''){
	        displayMessage = 'Please select the Category.';
	        helper.errorAlertToast(component,event,displayMessage);
	    }else if(selectedProject == ''){
	        displayMessage = 'Please select the Project.';
	        helper.errorAlertToast(component,event,displayMessage);
	    }else if(selectedDate == '' || selectedDate == null){
	        displayMessage = 'Please select the Date.';
	        helper.errorAlertToast(component,event,displayMessage);
	    }else if(selectedHours == '00' && selectedMinutes== '00'){
	        displayMessage = 'Please select the Hours or Minutes.';
	        helper.errorAlertToast(component,event,displayMessage);
	    }else{
	       var action = component.get("c.saveTimesheet");
           if(selectedtask == ''){
               selectedtask = 'NA';
           }
           if(selectedModule == ''){
               selectedModule = 'NA';
           }
	       action.setParams({
	           "category" : selectedCategory,
	           "project" : selectedProject,
	           "module" : selectedModule,
	           "task" : selectedtask,
	           "selectedDate" : selectedDate,
	           "hours" : selectedHours,
	           "taskStatus" : isCompleted,
	           "minutes" : selectedMinutes,
	           "description" : description
	       });
	       action.setCallback(this,function(response){
	           if(response.getState()=="SUCCESS"){
	                   var recordToDisply=response.getReturnValue();
	                   if(recordToDisply=='Records has been Saved Successfully'){
                                var a = component.get('c.doInit');
                                $A.enqueueAction(a);
                                helper.successAlertToast(component,event,recordToDisply);
                                component.find("categorySelectListId").set("v.value",'');
                                component.find("projectSelectListId").set("v.value",'');
                                component.find("moduleSelectListId").set("v.value",'');
                                component.find("taskSelectId").set("v.value",'');
                                component.find("statusCheckboxId").set("v.checked",false);
                                component.find("selectedDateId").set("v.value",'');
                                component.find("selectedHoursId").set("v.value",'00');
                                component.find("selectedMinutesId").set("v.value",'00');
                                component.find("descriptionId").set("v.value",'');
                                if(btnEvent=='Save'){
                                    $A.util.removeClass(tableID,"hideTimeSheet");
                                    $A.util.addClass(timeSheetID,"hideTimeSheet");
        	                   }else{
                                    $A.util.removeClass(timeSheetID,"hideTimeSheet");
                                    $A.util.addClass(tableID,"hideTimeSheet"); 
        	                   }
	                   }
	                   else{
	                       helper.errorAlertToast(component,event,recordToDisply);
	                   }
	           }
	       });
	       $A.enqueueAction(action);
	       //this.helper.getTimeSheet(component, page, recordToDisply);
	    }
	},
	Timesheetstay : function(component,event,helper){
	    component.find("categorySelectListId").set("v.value", "");
	    component.find("projectSelectListId").set("v.value", "");
	    component.find("moduleSelectListId").set("v.value", "");
	    component.find("taskSelectId").set("v.value", "");
	    component.find("statusCheckboxId").set("v.value", "");
	    component.find("selectedDateId").set("v.value", "");
	    component.find("selectedHoursId").set("v.value", "");
	    component.find("selectedMinutesId").set("v.value", "");
	    component.find("descriptionId").set("v.value", "");
	    var tableID = component.find("timesheettableId");
	    var timeSheetID = component.find('timesheetCalenderId');
        $A.util.removeClass(timeSheetID,"hideTimeSheet");
	   $A.util.addClass(tableID,"hideTimeSheet");
    },
	searchTimeSheetList : function(component,event,helper){
	    var page = 1;
        var recordToDisply = component.find("recordSize").get("v.value");
        //helper.searchTimeSheetHelper(component,event,helper,page,recordToDisply);
        helper.getTimeSheet(component, page, recordToDisply);
    },
    
    showCredentialDetails : function(component,event,helper){
        var selectedId = event.getSource().get("v.value");
        var action = component.get("c.credentialDetails");
        action.setParams({
            "Ids" : selectedId
        });
        action.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){
                component.set("v.credentialCompleteDetail",response.getReturnValue());
                component.set("v.modalpopupCredential",true);
            }
        });
        $A.enqueueAction(action);
    },
    
    
    searchCredentialProject : function(component,event,helper){
        component.set("v.credentials",[]);
        var selectedProject = component.find("selectProjectCreSearchId").get("v.value");
        if(selectedProject != ''){
            var action = component.get("c.searchCredentialDetails");
            action.setParams({
                "projectName": selectedProject
            });
            action.setCallback(this,function(response){
                if(response.getState()=="SUCCESS"){
                    component.set("v.credentials",response.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        }else{
            helper.getCredentials(component,event,helper);
        }
        
    },
    
    closeModel : function(component,event,helper){
        component.set("v.modalpopupCredential",false);
        component.set("v.modalpopupAddCredential",false);
    },
    dateFunction : function(component,event,helper){
        var today = new Date();
        var newdate = new Date();
        newdate.setDate(today.getDate()+1);
        var y= newdate.toISOString().slice(0,10);
        var selectedDate = component.find("selectedDateId").get("v.value");
        // alert(selectedDate);
        // alert(newdate);
        // alert(y);
        if(selectedDate == y){
            // alert("lalit");
            component.set("v.datefalse",true);
        }
    }
})