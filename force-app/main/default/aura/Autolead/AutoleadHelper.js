({
    /* getUrl : function(component,event,helper) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName,
            sParam,
            i;
        
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');
            
            if (sParameterName[0] === sParam) {
                return sParameterName[2] === undefined ? true : sParameterName[1];
                
            }
        }
            
        var url_string = window.location.href;
        var url1 = new URL(url_string);
        var urlId1 = url1.searchParams.get("id");    
        component.set("v.rId",urlId1);
        
        console.log(component.get("v.rId"));
    },  */
    
    action  : function(component, event, helper) {
        var action = component.get("c.creatLeadRecord");
        var mail=component.find('Email').get("v.value");
        
        
        action.setParams({
            "mMail": mail, 
            "leadObj":component.get("v.leadObj"),
            "recordId": component.get("v.rId")
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log(response.getState());
            console.log(response.getReturnValue());
            if (state == "SUCCESS") {
                var leadId = response.getReturnValue();  
                if(leadId == "Success"){
                     var leadId = response.getReturnValue();
                      alert('leadId'+leadId);
                    component.set("v.showError",false);
                    component.set("v.see",false);
                }
                
                if(leadId == 'Error'){
                    component.set("v.showError",false);
                    component.set("v.see",true);
                    
                }
            }
            else if(state == "Error"){
                var errors = response.getError();
                component.set("v.showError",true);
                component.set("v.errorMessage",errors[0].message);
            } 
        });
        $A.enqueueAction(action); 
    },
    
    /* valid : function(component, event, helper) {
        var inputField = component.find('FirstName');
        var value = inputField.get('v.value');
        if(value == null) {
            alert('please fill firstname');
            inputField.set("v.errors", [{message:"Enter a name " + value}]);
            
        } else {
            // Clear error
            inputField.set("v.errors", null);
        }     
    } */ 
    
    validation : function(component,event,helper){
        var a = component.find("FirstName").get("v.value"); 
        var b = component.find("LastName").get("v.value");
        var c = component.find("Company").get("v.value");
        var d = component.find("Email").get("v.value");
        var e = component.find("Phone").get("v.value");
        var f = component.find("CollegeName__c").get("v.value");
        var g = component.find("Profession__c").get("v.value");
        
        //  var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;    
        var myRe = /d(b+)d/g;
        var phoneno = /^\d{10}$/;
        
        
        
        
        
        
        if(a != null && a != '' && b != null && b != '' && c != null && c != '' && d != null && d != ''  && e != null && e != '' && f != null && f != '' && g != null && g != '' && a.match(/^[a-zA-Z ]*$/) && b.match(/^[a-zA-Z ]*$/) && d.match(/^\S+@\S+\.\S+$/) && e.match(/^[0-9]{10}$/)){
            component.set("v.disabled",false);
        }else{
            component.set("v.disabled",true);
        }
    },
    
})