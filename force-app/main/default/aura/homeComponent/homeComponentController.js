({
	doInit : function(component, event, helper) {
		console.log('Inside');
        var url = $A.get('$Resource.backgroundImage');
        component.set('v.backgroundImageURL', url);
	},
    checkCredential : function(component, event, helper) {
        console.log('Inside check ');
        var homep = component.find("homepage");
        console.log(homep);
        var log = component.find("logId");
        console.log(log);
        $A.util.addClass(log,'formhide');
		$A.util.removeClass(homep, 'formhide');
	},
    
    setRedirectTabname : function(component,event,helper){
		var tabName = event.getParam('redirectTabName');
        component.set('v.tabName',tabName);
    }
})