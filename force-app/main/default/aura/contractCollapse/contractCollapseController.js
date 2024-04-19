({
    doInit : function(component, event, helper) {
       console.log('Child controller');
        
		var action = component.get("c.getContractDetails");
        action.setParams({
            "ids":"a016F00001eMNqUQAW"
        });
        
        action.setCallback(this,function(response){
            console.log('before');
            var state = response.getState();
            if(state=="SUCCESS"){
                console.log('aftrer');
                var ret = response.getReturnValue();
                component.set("v.contractList",ret);
                console.log(ret);
            }
        });
        $A.enqueueAction(action);
  	},
    sectionOne : function(component, event, helper) {
       helper.helperFun(component,event,'articleOne');
    },
    
   sectionTwo : function(component, event, helper) {
      helper.helperFun(component,event,'articleTwo');
    },
   
   sectionThree : function(component, event, helper) {
      helper.helperFun(component,event,'articleThree');
   },
   
   sectionFour : function(component, event, helper) {
      helper.helperFun(component,event,'articleFour');
   },
   
   sectionFive : function(component, event, helper) {
      console.log('Section Five');
      helper.helperFun(component,event,'articleFive');
   },
})