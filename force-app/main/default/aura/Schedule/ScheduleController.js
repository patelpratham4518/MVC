({
    doInit: function(component, event, helper) {
        helper.doInit(component, event, helper);
        // helper.getPickListValues(component, event, helper, 'Interview__c','Interviewer__c', 'picklist1');
        helper.getPickListValues(component, event, helper, 'Interview__c', 'Result__c', 'picklist2');
        helper.test(component, event, helper);
        helper.reschedule(component, event, helper);
        helper.pdf(component, event, helper);

        // To check current site url has interview id or not
        var url_string = window.location.href;
        var url1 = new URL(url_string);
        var urlId1 = url1.searchParams.get("interviewid");



        if (urlId1 == '' || urlId1 == null) {
            component.set("v.authenticated", "true");
        }
        if (urlId1 != null) {

            component.set("v.authenticated", "false");
        }


    },
    validate: function(component, event, helper) {
        helper.validate(component, event, helper);

    },
    schedule: function(component, event, helper) {
        console.log('In>>');
        helper.schedule(component, event, helper);
    },
    submit: function(component, event, helper) {
        helper.submit(component, event, helper);
    },
    attachment: function(component, event, helper) {
        helper: attachment(component, event, helper);
    },
    onCheck: function(cmp, evt) {
        var checkCmp = cmp.find("checkbox");
        cmp.set("v.meetornot",checkCmp.get("v.value"));
    }
})