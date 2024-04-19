({
	checkCredential : function(component, event, helper) {
        console.log('Inside check ');
        var homep = component.find("homepage");
        var log = component.find("logId");
        $A.util.addClass(log,'formhide');
		$A.util.removeClass(homep, 'formhide');
	}
})