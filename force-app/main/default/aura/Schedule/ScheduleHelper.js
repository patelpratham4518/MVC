({
    doInit: function(component, event, helper) {
        var url_string = window.location.href;
        var url = new URL(url_string);
        var urlId = url.searchParams.get("id");

        component.set("v.test", urlId);

        var action = component.get("c.getInterviewers");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                component.set("v.interviewerList", response.getReturnValue());
                component.get("v.interviewerList");
            }
        });
        $A.enqueueAction(action);

    },

    //To Preview Pdf
    pdf: function(component, event, helper) {
        var action = component.get("c.pdfview");
        action.setParams({
            'reid': component.get("v.test")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var pdf = response.getReturnValue().split(',');
                var link = "data:" + pdf[0] + ";base64," + pdf[1];
                component.set("v.pdfvalue", link);
            }
        });
        $A.enqueueAction(action);

    },

    // To get Round and Name and Posting
    test: function(component, event, helper) {
        var action = component.get("c.test");
        action.setParams({
            'reid': component.get("v.test")

        });

        action.setCallback(this, function(response) {
            console.log({response});
            var state = response.getState();

            if (state === "SUCCESS") {

                var some = response.getReturnValue().split(',');
                if (some[0] == 'new') {
                    component.set("v.num", "1st");

                }
                if (some[0] == 'first') {
                    component.set("v.num", "2nd");
                    component.set("v.num1", "1st");
                    component.set("v.firstinter", some[7]);
                    component.set("v.firint", true);


                }
                if (some[0] == 'second') {
                    component.set("v.num1", "2nd");
                }
                component.set('v.name', some[1]);
                component.set('v.posting', some[2]);
                component.set('v.spinner', false);
                component.set('v.con.Email', some[3]);
                component.set('v.con.Exp', some[4]);
                component.set('v.con.FE', some[5]);
                component.set('v.con.phone', some[6]);
            }
        });
        $A.enqueueAction(action);
    },

    // For Rescheduling Page
    reschedule: function(component, event, helper) {
        var action = component.get("c.resch");
        action.setParams({
            'reid': component.get("v.test")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                if (response.getReturnValue() != null) {
                    var xyz = response.getReturnValue().split(',');

                    if (xyz[0] == 're') {
                        component.set("v.re", "Re-");

                        if (xyz[1] == 'First') {
                            component.set("v.num", "1st");
                        } else if (xyz[1] == 'Second') {
                            component.set("v.num", "2nd");
                        }

                    } else {
                        component.set("v.re", "");
                    }

                } else {
                    component.set("v.re", "");
                }

                if (response.getReturnValue() != null) {

                    var xy = response.getReturnValue().split(',');



                    component.set("v.cs", xy[2]);
                    component.set("v.sas", xy[3]);
                    component.set("v.sda", xy[4]);
                    component.set("v.fs", xy[5]);
                    component.set("v.js", xy[6]);
                    component.set("v.gc", xy[7]);
                    component.set("v.dc", xy[8]);
                    component.set("v.prof", xy[9]);
                    component.set("v.result", xy[10]);

                }



                component.set('v.spinner', false);
            }
        });
        $A.enqueueAction(action);
    },


    //For Validation
    validate: function(component, event, helper) {
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        var date1 = component.get("v.date");
        var x = component.find("interviewer").get("v.validity");
        var y = component.find("time").get("v.validity");
        /*console.log(x.valid+'x');
            console.log(y.valid+'y');*/
        if (x.valid == false || y.valid == false || date1 == null || date1 == '' || date1 < today) {
            component.set("v.disabled", "true");
        } else if (x.valid == true && y.valid == true && date1 >= today) {
            component.set("v.disabled", "false");
        }
    },

    // Scheduling Helper

    schedule: function(component, event, helper) {
        console.log('In helper');
        var action = component.get("c.scheduling");


        action.setParams({
            'inter': component.get("v.interviewer"),
            dt: component.get("v.date"),
            'tm': component.get("v.time"),
            'reid': component.get("v.test"),
            'meetornot': component.get("v.meetornot")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log({response});
            console.log({state});
            if (state === "SUCCESS") {

                component.set("v.msg", "false");
            }
        });
        $A.enqueueAction(action);
    },

    // Result submit Helper

    submit: function(component, event, helper) {
        var url_string = window.location.href;
        var url1 = new URL(url_string);
        var urlId1 = url1.searchParams.get("interviewid");

        var action = component.get("c.submitrecord");

        action.setParams({
            'cs': component.get("v.cs"),
            'sas': component.get("v.sas"),
            'sda': component.get("v.sda"),
            'fs': component.get("v.fs"),
            'js': component.get("v.js"),
            'gc': component.get("v.gc"),
            'dc': component.get("v.dc"),
            'prof': component.get("v.prof"),
            'result': component.get("v.result"),
            'interid': urlId1
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.msg1", "false");
            }
        });
        $A.enqueueAction(action);
    },

    getPickListValues: function(component, event, helper, objectName, FieldName, AttributName) {
        var status = component.get("c.getPickListValues");
        status.setParams({
            'ObjName': objectName,
            'FieldName': FieldName
        });
        status.setCallback(this, function(response) {
            var allValues = response.getReturnValue();

            component.set("v." + AttributName, allValues);
        });
        $A.enqueueAction(status);
    }

})