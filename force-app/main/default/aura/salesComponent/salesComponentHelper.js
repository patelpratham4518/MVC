({
	getAllRecords : function(component,event,u) {
        console.log(u);
		var action = component.get("c.getSalesList");
        action.setParams({
            "accId":u
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state=="SUCCESS"){
                var res = response.getReturnValue();
                component.set("v.salesList",res);
                console.log(res);
            }
        });
        $A.enqueueAction(action);
	}
})