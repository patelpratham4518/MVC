({
	getAllRecords : function(component,event,u) {
		var action = component.get("c.getRebateList");
        action.setParams({
            "accId":u
        	});
            
        action.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){
                var res = response.getReturnValue();
                component.set("v.rebateList",res);
                console.log(res);
            }
        });
        $A.enqueueAction(action);
	},
    
    currentUserDetails : function(component,event,helper){
        console.log('Inside User Details');
        var action = component.get("c.userDetails");
       	 action.setCallback(this,function(res){
            if(res.getState()=="SUCCESS"){
                var u = res.getReturnValue();
                component.set('v.userID',u);
                console.log('Inside success');
                console.log(u);
            }
        });
        $A.enqueueAction(action);
        return u;
    }
    
})