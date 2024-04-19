({
    scriptsLoaded : function(component, event, helper) {
        console.log('controller');
        helper.loadCalendar(component);
    },
});