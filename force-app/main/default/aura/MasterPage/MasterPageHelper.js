({
    doInit: function(component, event, helper) {
    var action = component.get("c.iptest");
    console.log('hey');
    action.setCallback(this, function(response){
       var state= response.getState();
       console.log(response.getState());
       if(state === "SUCCESS"){
           var ipval = response.getReturnValue();
           console.log({ipval});
           if(ipval == true){
            component.set("v.password", true);   
           }else{
            component.set("v.password", false);
           }
       }else if (state === "INCOMPLETE") {
                alert('Response is Incompleted');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " +
                            errors[0].message);
                    }
                } else {
                    alert("Unknown error");
                }
            }
    });
    $A.enqueueAction(action);

    },
    SearchHelper: function(component, event, helper) {
        // show spinner message
        component.find("Id_spinner").set("v.class", 'slds-show');
        var action = component.get("c.fetchContact");
        action.setParams({
            'searchKeyWord': component.get("v.searchKeyword")
        });
        action.setCallback(this, function(response) {
            // hide spinner when response coming from server 
            component.find("Id_spinner").set("v.class", 'slds-hide');
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();

                // if storeResponse size is 0 ,display no record found message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", true);
                } else {
                    component.set("v.Message", false);
                }

                // set numberOfRecord attribute value with length of return value from server
                component.set("v.TotalNumberOfRecord", storeResponse.length);

                // set searchResult list with return value from server.
                component.set("v.searchResult", storeResponse);

            } else if (state === "INCOMPLETE") {
                alert('Response is Incompleted');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " +
                            errors[0].message);
                    }
                } else {
                    alert("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    // TO PREVIEW PDF
    pdf: function(component, event, helper, buttonId) {
        var action = component.get("c.pdfview");

        action.setParams({
            'reid': buttonId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var pdf = response.getReturnValue().split(',');
                var link = "data:" + pdf[0] + ";base64," + pdf[1];
                component.set("v.pdfvalue", link);
                // component.set("v.authenticated", false);
            }
        });
        $A.enqueueAction(action);

    },

    scheduleShowHelper: function(component, event, helper, buttonName, buttonId) {
        var action = component.get("c.scheduleShow");
        console.log(buttonName);
        console.log(buttonId);
        action.setParams({
            'conid': buttonId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(response.getReturnValue());
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.authenticated", false);
                if (buttonName == '1st') {
                    if (result == 'New') {
                        component.set("v.schedule", true);
                        component.set("v.buttons", false);
                    }
                    if (result == 'First' || result == 'Second') {
                        component.set("v.schedule", false);
                        component.set("v.buttons", true);
                    }
                }
                if (buttonName == '2nd') {
                    if (result == 'Second') {
                        component.set("v.schedule", true);
                        component.set("v.buttons", false);
                    }
                    if (result == 'New' || result == 'First') {
                        component.set("v.schedule", false);
                        component.set("v.buttons", true);
                    }
                }

            }
        });
        $A.enqueueAction(action);
    },

    ShowInterview: function(component, event, helper, buttonId, RoundName) {
        var action = component.get("c.getInterviewId");
        console.log('hey');
        action.setParams({
            'conid': buttonId,
            'RoundName': RoundName
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            console.log(response.getReturnValue());
            if (state === "SUCCESS") {
                var result = response.getReturnValue();

                component.set("v.InterviewID", result);
                component.set("v.buttons", false);
                component.set("v.schedule", true);
                component.set("v.ShowOrSche", false);
            }
        });
        $A.enqueueAction(action);
    },
})