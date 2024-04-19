({
    getImages : function(component, event, helper){
        var url_string = window.location.href;
        var url = new URL(url_string);
        var urlId = url.searchParams.get("id");
        var action = component.get("c.getContents");
        // component.set("v.Spinner",true);
        console.log(urlId);
        action.setParams({
            "jobID" : urlId,
            "fatchedRecordNo" : component.get("v.fatchedRecordNo")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('datas');
                console.log(result);
                component.set('v.Gallaryfiles', result);
            }
        });
        $A.enqueueAction(action);
    },
    
    showToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Info!",
            "type" : "info",
            "message": "No more files found."
        });
        toastEvent.fire();
    },
    attach: function(component,event,helper){
        var url_string = window.location.href;
        var url = new URL(url_string);
        var urlId = url.searchParams.get("id");
        
        var action=component.get("v.testw");
        action.setParams({
            "jid": '0036F00003cFcSyQAK'
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.files1",result);
            }
            
        });
        $A.enqueueAction(action);
        
    }
})