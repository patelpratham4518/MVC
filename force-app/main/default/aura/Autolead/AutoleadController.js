({
    doInit:function(component,event,helper){
        var url_string = window.location.href;
        var url1 = new URL(url_string);
        var urlId1 = url1.searchParams.get("id");    
        component.set("v.rId",urlId1);
        
        
        console.log(component.get("v.rId"));
    },
    doAction : function(component, event, helper) {
        //helper.getUrl(component,event,helper);
        helper.action(component, event, helper);
    },
    
    
    
    /*  validation: function(component,event,helper){
        helper.validation(component,event,helper);  
    }, */  
    validateAge: function(component,event,helper){
        helper.validation(component,event,helper);
    },
    Form:function(component,event,helper){
        component.set("v.showError",true);
    },
    Register:function(component,event,helper){
        
    }
})