({
    doInit: function(component, event, helper) {

    },
    getpostings: function(component, event, helper) {
        var action = component.get("c.getposting");

        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(response.getReturnValue());
            if (state === "SUCCESS") {


                component.set("v.postings", response.getReturnValue());

            }
        });
        $A.enqueueAction(action);
    },

})