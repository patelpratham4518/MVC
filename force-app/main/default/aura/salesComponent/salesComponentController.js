({
	doinit : function(component, event, helper) {
        var action = component.get("c.userDetails");
        action.setCallback(this,function(res){
            if(res.getState()=="SUCCESS"){
                var u = res.getReturnValue();
                component.set('v.userName',u);
                helper.getAllRecords(component,event,u);
            }
        });
        $A.enqueueAction(action);
		
	},
    searchDate : function(component,event,helper){
        component.set('v.message','');
        var action1 = component.get("c.userDetails");
        action1.setCallback(this,function(res){
            if(res.getState()=="SUCCESS"){
                var u = res.getReturnValue();
                component.set('v.userName',u);
                var d = component.find("selectedDueDate");
        		var dValue = d.get("v.value");
        		console.log(dValue);
        		if(dValue!=null){
            		component.set("v.salesList",[]);
            		var action = component.get("c.getSearchResult");
            		action.setParams({
                		"abc": dValue,
                		"uID": u
                	});
            
            	action.setCallback(this,function(response){
                var state = response.getState();
                if(state=="SUCCESS")
                {
                    var res = response.getReturnValue();
                    component.set("v.salesList",res);
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