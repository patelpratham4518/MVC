({
	helperFun : function(component,event,secId) {
      console.log('calling three helper');
	  var acc = component.find(secId);
        	for(var cmp in acc) {
            console.log('calling inside');
        	$A.util.toggleClass(acc[cmp], 'slds-show');  
        	$A.util.toggleClass(acc[cmp], 'slds-hide');  
       }
	},
})