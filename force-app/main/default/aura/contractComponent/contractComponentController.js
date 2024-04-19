({
	doInit : function(component, event, helper) {
//         console.log('Child controller');
//         console.log('calling User ')
// 		var action1 = component.get("c.userDetails");
//         action1.setCallback(this,function(res){
//             if(res.getState()=="SUCCESS"){
//                 var u = res.getReturnValue();
//                 component.set('v.userName',u);
//                 console.log(u);
                var action = component.get("c.getContractDetails");
        // 			action.setParams({
        //     		"uID":u
        // 			});
        
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
        //     }
        // });
        // $A.enqueueAction(action1);
		
	},
    sectionOne : function(component, event, helper) {
       helper.helperFun(component,event,'articleOne');
    },
    
   sectionTwo : function(component, event, helper) {
      helper.helperFun(component,event,'articleTwo');
    },
   
   sectionThree : function(component, event, helper) {
      console.log('calling three');
      helper.helperFun(component,event,'articleThree');
   },
   
   sectionFour : function(component, event, helper) {
      helper.helperFun(component,event,'articleFour');
   },
    
   showDetails : function(component,event,helper){
      console.log('calling show details');
      var tablerecord = component.find("recordTable");
      var singleRecord = component.find("detailsSection");
      var backTo = component.find("backToID");
      var btn = event.getSource();
      var recordId = btn.get("v.name");
      console.log(recordId);
      var action = component.get("c.getViewDetails");
       action.setParams({
           "record":recordId
       });
       action.setCallback(this,function(response){
           if(response.getState()=="SUCCESS"){
               var returnVal = response.getReturnValue();
               component.set("v.recordDetails",returnVal);
               console.log(returnVal);
               $A.util.addClass(tablerecord,'details');
               $A.util.removeClass(singleRecord,'details');
               $A.util.removeClass(backTo,'details');
           }
       });
       $A.enqueueAction(action);
   },
   
    backToList : function(component,event,helper){
      var tablerecord = component.find("recordTable");
      var singleRecord = component.find("detailsSection");
      var backTo = component.find("backToID");
      $A.util.addClass(singleRecord,'details');
      $A.util.removeClass(tablerecord,'details');
      $A.util.addClass(backTo,'details');
    }

})