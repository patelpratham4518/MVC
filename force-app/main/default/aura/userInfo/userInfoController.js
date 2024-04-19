({
	doInit : function(component, event, helper) {
        console.log('calling User ')
		var action = component.get("c.userDetails");
        action.setCallback(this,function(res){
            if(res.getState()=="SUCCESS"){
                var u = res.getReturnValue();
                component.set('v.userName',u);
                console.log(u);
            }
        });
        $A.enqueueAction(action);
	}
})