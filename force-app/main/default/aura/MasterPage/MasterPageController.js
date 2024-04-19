({
    doInit: function(component, event, helper) {
        helper.doInit(component, event, helper);
        // var url_string = window.location.href;
        // var url1 = new URL(url_string);
        // var urlId1 = url1.searchParams.get("Password");

        // if (urlId1 != "Mvclouds@1") {
        //     component.set("v.password", false);
        // }
    },

    Search: function(component, event, helper) {
        var searchField = component.find('searchField');
        var isValueMissing = searchField.get('v.validity').valueMissing;
        // if value is missing show error message and focus on field
        if (isValueMissing) {
            searchField.showHelpMessageIfInvalid();
            searchField.focus();
        } else {
            // else call helper function 
            helper.SearchHelper(component, event, helper);
        }
    },

    scheduleShowController: function(component, event, helper) {

        var buttonName = event.getSource().getLocalId();
        var buttonId = event.getSource().get("v.name");

        component.set("v.ConId", buttonId);
        helper.pdf(component, event, helper, buttonId);

        console.log(buttonName);
        console.log(buttonId);

        if (buttonName == '1st') {
            component.set("v.RoundNumber", '1st');
            helper.scheduleShowHelper(component, event, helper, buttonName, buttonId);
        }
        if (buttonName == '2nd') {
            component.set("v.RoundNumber", '2nd');
            helper.scheduleShowHelper(component, event, helper, buttonName, buttonId);
        }

    },

    schedule: function(component, event, helper) {

    },

    ShowOrSchedule: function(component, event, helper) {
        var buttonName = event.getSource().get("v.name");
        var buttonId = component.get("v.ConId");
        var RoundName = component.get("v.RoundNumber");
        if (buttonName == 'Show') {
            helper.ShowInterview(component, event, helper, buttonId, RoundName);
        }

        if (buttonName == 'Re-schedule') {
            component.set("v.buttons", false);
            component.set("schedule", true);
            component.set("v.ShowOrSche", true);
        }
    },
})