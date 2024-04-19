({
    doInit: function(component, event, helper) {
        helper.doInit(component, event, helper);
        helper.getpostings(component, event, helper);


    },
    change: function(component, event, helper) {
        //component.set("v.spinner",true);
        var xyz = component.get("v.checkVal");
        var wh = event.getSource().get("v.name"); 

		/*var wh = component.find("PostingName").get("v.value");
        var xy = component.get("v.icon");*/

        if (xyz == wh) {
            component.set("v.checkVal", "");
			//component.set("v.spinner",false);            
        } else {
            component.set("v.checkVal", wh);
          //  component.set("v.spinner",false);
        } 
    },

    goToFormPage: function(component, event, helper) {

        var urlEvent = $A.get("e.force:navigateToURL");
        var xyz = event.getSource().get("v.name");
        console.log(urlEvent);
        console.log(xyz);
        // urlEvent.setParams({
        //     "url": "/ApplicationUI?Id/" + xyz
        // });

        // urlEvent.fire();

        window.open('https://dharmikmvclouds-developer-edition.ap4.force.com/ApplicationUI?Id=' + xyz, '_self');
    },


})