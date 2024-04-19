({
	doInit : function(component, event, helper) {
	    var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
               // set current user information on userInfo attribute
                component.set("v.userInfo", storeResponse);
            }
        });
        $A.enqueueAction(action);
	},
	
	openPopup : function(component,event,helper){
	    var selectedValue = event.getParam("value");
	    if(selectedValue == 'ChangePassoword'){
	        component.set("v.modalPopupChangePassword",true);
	    }else if(selectedValue == 'MyProfile'){
	        component.set("v.modalPopupProfile",true);
	    }else if(selectedValue == 'Logout'){
	       var returnUrl='https://dharmikmv-developer-edition.ap4.force.com/MVCloudsPortal/secur/logout.jsp?retUrl=https%3A%2F%2Fdharmikmv-developer-edition.ap4.force.com%2FMVCloudsPortal%2Fs%2Flogin%2F'; 
	        // window.location.replace("https://dharmikmv-developer-edition.ap4.force.com/MVCloudsPortal/servlet/networks/switch?startURL=%2Fsecur%2Flogout.jsp");
	        window.location.href=returnUrl;
	    }
	},
	
	closeModel : function(component,event,helper){
	    component.set("v.modalPopupChangePassword",false);
	    component.set("v.modalPopupProfile",false);
	},
	
	lalit : function(component , event , helper){
	    //var CurrentPass= component.find("currentPassword").get("v.value");
	    var NewPass= component.find("NewPassword").get("v.value");
	    var ConformPass= component.find("confirmPassword").get("v.value");
	    var action = component.get("c.checkPass");
	    alert(NewPass);
	    alert(ConformPass);
	    if(NewPass!= ConformPass){
	        //alert('passCheck');
	        component.set("v.passCmp",true);
	        component.set("v.passCheck",false);
	        component.set("v.prevPass", false);
	    }else{
    	    action.setParams({
                     "Cpass" : ConformPass
            });
    	    action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    if(storeResponse==true){
                        component.set("v.passCheck", storeResponse);
                        component.set("v.passCmp", false);
                        component.set("v.prevPass", false);
                        $A.get('e.force:refreshView').fire();
                    }else{
                        component.set("v.prevPass", true);
                        component.set("v.passCheck", false);
                        component.set("v.passCmp", false);
                    }
                }
            });
            $A.enqueueAction(action);
    	}
	}
})