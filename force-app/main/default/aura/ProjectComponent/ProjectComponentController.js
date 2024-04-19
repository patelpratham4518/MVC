({
	doInit : function(component, event, helper) {
	    helper.getProjectsDetails(component,event,helper);
	    helper.fetchImportantTopic(component,event,helper);
	},
	
	projectComponentCompleteDetails : function(component,event,helper){
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
                var modulesListRelatedToProject = response.getReturnValue();
                component.set("v.modulesList",modulesListRelatedToProject[0].Modules__r);
                component.set("v.modalpopupProjectDetails",true);
            }
        });
        $A.enqueueAction(action);
	},
	
	closeModel: function(component, event, helper) {
      component.set("v.modalpopupProjectDetails", false);
      component.set("v.modalpopupAddTopic",false);
      
   },
   waiting: function(component, event, helper) {
	    
        component.set("v.HideSpinner", true);
    },
    
    doneWaiting: function(component, event, helper) {
        component.set("v.HideSpinner", false);
    },
   
    openAddTopicPopup : function(component,event,helper){
      component.set("v.modalpopupAddTopic",true);
	},
	
	addTopic : function(component,event,helper){
	    var topicName = component.find("topicNameId").get("v.value");
	    var url = component.find("urlId").get("v.value");
	    var displayMessage = '';
	    
	    if(topicName == ''){
	        displayMessage = 'Please enter the Topic Name';
	        helper.errorAlertToast(component,event,displayMessage);
	    }else if(url == ''){
	        displayMessage = 'Please enter the URL.';
	        helper.errorAlertToast(component,event,displayMessage);
	    }else{
	        var action = component.get("c.saveTopics");
	        action.setParams({
	           "topicName" : topicName,
	           "url" : url
	        });
	        action.setCallback(this,function(response){
	            if(response.getState()=="SUCCESS"){
	                if(response.getReturnValue() == "Success"){
	                    helper.successAlertToast(component,event,helper);
	                }
	            }
	        });
	        $A.enqueueAction(action);
	    }
	},
    
    redirectToTaskComponent : function(component,event,helper){
        var value = event.getSource().get('v.value');
        alert(value);
        var setTabName = 'task';
        var tabNameEvent = component.getEvent("tabSpecificEvent");
        
         var evt=$A.get("e.c:ProjectEvent");
         evt.setParams({"Pass_Result": value});
        
   		
        tabNameEvent.setParams({
            redirectTabName : setTabName
        });
        tabNameEvent.fire();
        evt.fire();
    },
    
    redirectToTimesheetComponent : function(component,event,helper){
        var value = event.getSource().get('v.value');
        alert(value);
        var setTabName = 'timesheet';
        var tabNameEvent = component.getEvent("tabSpecificEvent");
   		
   		var evt=$A.get("e.c:ProjectEvent");
        evt.setParams({"Pass_Result": value});
        
        tabNameEvent.setParams({
            redirectTabName : setTabName
        });
        tabNameEvent.fire();
        evt.fire();
    },
    
    redirectToManageProject : function(component,event,helper){
        var setTabName = 'manage';
        var tabNameEvent = component.getEvent("tabSpecificEvent");
   		
        tabNameEvent.setParams({
            redirectTabName : setTabName
        });
        tabNameEvent.fire();
    }
})