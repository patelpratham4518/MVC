({
	getCredentials : function(component,event,helper,searchValue){
      var action = component.get("c.credentialList");  
      action.setParams({
                "credentialName" : searchValue
        });
      action.setCallback(this,function(response){
          if(response.getState()=="SUCCESS"){
              console.log('credentials');
              console.log(response.getReturnValue());
              component.set("v.credentials",response.getReturnValue());
          }
      });
      $A.enqueueAction(action);
    },
    getProject : function(component,event,helper,searchValue){
        var action = component.get("c.getProjects");  
        
        action.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){
                component.set("v.projectList",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    errorAlertToast :function(component,event,displayMessage){
	    var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error Message',
            message: displayMessage,
            key: 'info_alt',
            type: 'error',
            mode: 'dismissible'
        });
        toastEvent.fire();
	},
	
	successAlertToast : function(component,event,setTabName){
	    var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message: 'Records has been Saved Successfully',
            key: 'info_alt',
            type: 'success',
            mode: 'dismissible'
        });
        toastEvent.fire();
        //$A.get('e.force:refreshView').fire();
	},
})