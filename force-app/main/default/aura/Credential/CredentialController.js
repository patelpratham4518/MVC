({
	doInit : function(component, event, helper) {
	    var searchValue='';
      helper.getCredentials(component,event,helper,searchValue);
      helper.getProject(component,event,helper,searchValue);
	},
	
	addCredentialPopup : function(component,event,helper){
        component.set("v.modalpopupAddCredential",true);
    },
	
    saveCredential : function(component,event,helper){
        var displayMessage = '';
        var selectedProject = component.find("selectProjectCreId").get("v.value");
        var username = component.find("userNameId").get("v.value");
        var password = component.find("passwordId").get("v.value");
        var orgType = component.find("selectOrgTypeId").get("v.value");
        var securityToken = component.find("securityTokenId").get("v.value");
        
        if(selectedProject == ''){
            displayMessage = 'Please Select the Project.'
            helper.errorAlertToast(component,event,displayMessage);
        }else if(username == ''){
            displayMessage = 'Enter the Username.';
            helper.errorAlertToast(component,event,displayMessage);
        }else if(password == ''){
            displayMessage = 'Enter the Password.';
            helper.errorAlertToast(component,event,displayMessage);
        }else if(orgType == ''){
            displayMessage = 'Please Select the Org.';
            helper.errorAlertToast(component,event,displayMessage);
        }else{
            var action = component.get("c.saveNewCredential");
            if(securityToken == ''){
                securityToken = 'NA';
            }
            action.setParams({
                "project" : selectedProject,
                "username" : username,
                "password" : password,
                "org" : orgType,
                "securityToken" : securityToken
            });
            action.setCallback(this,function(response){
                if(response.getState()=="SUCCESS"){
                    if(response.getReturnValue() == "Success"){
                        var setTabName = 'timesheet';
                        helper.getCredentials(component,event,helper);
                        helper.successAlertToast(component,event,setTabName);
                        component.set("v.modalpopupAddCredential",false);
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
    closeModel : function(component,event,helper){
        component.set("v.modalpopupAddCredential",false);
    },
    searchCredential : function(component,event,helper){
        var searchValue = component.find("inputCredential").get("v.value"); 
        helper.getCredentials(component,event,helper,searchValue);
    }
})