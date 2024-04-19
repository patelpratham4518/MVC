({
	loadChevron : function(component, event, helper) {		
        var action = component.get('c.getChevronData');
		var txt_recordId = component.get("v.recordId");
		var txt_FieldName = component.get("v.fieldName");
         action.setParams({
            recordId : txt_recordId,
            fieldName : txt_FieldName 
        });
        action.setStorable();        
        action.setCallback(this, function(res) { 
            helper.handleCallback(component, event, helper,res); 
        }); 
        $A.enqueueAction(action);  
	},
    handleCallback : function(component, event, helper,res){
        if (res.getState() === 'SUCCESS') { 
            var retJSON = JSON.parse(res.getReturnValue());  
            component.set("v.records",retJSON);
        }
    }
})