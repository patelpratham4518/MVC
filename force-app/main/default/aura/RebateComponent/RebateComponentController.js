({
	doinit : function(component, event, helper) {
         //helper.getAllRecords(component,event,helper);
	     var action = component.get("c.userDetails");
       	 action.setCallback(this,function(res){
            if(res.getState()=="SUCCESS"){
                var u = res.getReturnValue();
                component.set('v.userName',u);
                helper.getAllRecords(component,event,u);
            }
        });
        $A.enqueueAction(action);
        //var u = helper.currentUserDetails(component,event,helper);
        //console.log('Returned user ID');
        //console.log(u);
        //helper.getAllRecords(component,event,u);
	},
    searchStart : function(component,event,helper){
        component.set('v.message','');
        var action1 = component.get("c.userDetails");
       	 action1.setCallback(this,function(res){
            if(res.getState()=="SUCCESS"){
                var u = res.getReturnValue();
                component.set('v.userName',u);
				var d = component.find("selectedStart");
				var dValue = d.get("v.value");
        		console.log(dValue);
        		console.log('userId'+u);
        		if(dValue!=null){
            		component.set("v.rebateList",[]);
            		var action = component.get("c.getSearchRebateList");
            		action.setParams({
                		"startdt": dValue,
                		"uID" : u
            	});
            	action.setCallback(this,function(response){
                	var state = response.getState();
                	if(state=="SUCCESS")
                	{
                    	var res = response.getReturnValue();
                    	component.set("v.rebateList",res);
                    	console.log(res);
                    	if(res=='' || res==null){
                        	component.set('v.message','No records found');
                    	}
                	}
            	});
            $A.enqueueAction(action);
        	}else{
            	component.set('v.message','');
                helper.getAllRecords(component,event,u);
        	}                
        }
      });
      $A.enqueueAction(action1);     
    }
})