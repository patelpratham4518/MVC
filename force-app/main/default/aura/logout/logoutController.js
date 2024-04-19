({
	doInit : function(component, event, helper) {
       /* console.log('inside user contact');
        var action = component.get("c.userName");
        action.setCallback(this,function(res){
            if(res.getState()=="SUCCESS"){
                var result = res.getReturnValue();
                console(result);
            }
        });
        $A.enqueueAction(action);*/
	},
    
    logout : function(component,event,helper){
        window.location.replace("https://dharmikmv-developer-edition.ap4.force.com/s/login/");
    }
})