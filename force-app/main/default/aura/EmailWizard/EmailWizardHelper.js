//buildNewAccountOverrideHelper.js
({
	toggleOneAndTwoSteps : function(component) {
		var stepOne = component.find("stepOne");
        console.log({stepOne});
        $A.util.toggleClass(stepOne, 'slds-hide');
        var stepTwo = component.find("stepTwo");
        $A.util.toggleClass(stepTwo, 'slds-hide');
	},
    toggleTwoAndThreeSteps : function(component){
        var stepTwo = component.find("stepTwo");
        $A.util.toggleClass(stepTwo, 'slds-hide');
        var stepThree = component.find("stepThree");
        $A.util.toggleClass(stepThree, 'slds-hide');
    },
    toggleThreeAndFourSteps : function(component){
        var stepThree = component.find("stepThree");
        $A.util.toggleClass(stepThree, 'slds-hide');
        var stepFour = component.find("stepFour");
        $A.util.toggleClass(stepFour, 'slds-hide');
    },
    toggleThreeAndOneSteps : function(component){
        var stepTwo = component.find("stepTwo");
        $A.util.toggleClass(stepTwo, 'slds-hide');
        var stepThree = component.find("stepThree");
        $A.util.toggleClass(stepThree, 'slds-hide');
        var stepFour = component.find("stepFour");
        $A.util.toggleClass(stepFour, 'slds-hide');
    },
    // navigate to next pagination record set   
    next : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i = end + 1; i < end + pageSize + 1; i++){
            if(sObjectList.length > i){ 
                if(component.find("selectAllId").get("v.value")){
                    Paginationlist.push(sObjectList[i]);
                }else{
                    Paginationlist.push(sObjectList[i]);  
                }
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    // navigate to previous pagination record set   
    previous : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                if(component.find("selectAllId").get("v.value")){
                    Paginationlist.push(sObjectList[i]);
                }else{
                    Paginationlist.push(sObjectList[i]); 
                }
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    getAllLeads: function(component,event,helper,objname){
        console.log({objname});
        var action = component.get("c.fetchAccountWrapper");
        action.setParams({
            "objname" : objname
        });
        action.setCallback(this, function(response) {
            console.log('fetchAccountWrapper-->',{response});
            var state = response.getState();
            if (state === "SUCCESS"){
                var oRes = response.getReturnValue();
                console.log({oRes});
                if(oRes.length > 0){
                    component.set("v.bNoRecordsFound" , false);
                    component.set('v.listOfAllAccounts', oRes);
                    var pageSize = component.get("v.pageSize");
                    var totalRecordsList = oRes;
                    var totalLength = totalRecordsList.length ;
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    
                    var PaginationLst = [];
                    for(var i=0; i < pageSize; i++){
                        if(component.get("v.listOfAllAccounts").length > i){
                            console.log('oRes-->',oRes[i]);
                            PaginationLst.push(oRes[i]);    
                        } 
                    }
                    console.log({PaginationLst});
                    component.set('v.PaginationList', PaginationLst);
                    component.set("v.selectedCount" , 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));
                }else{
                    // if there is no records then display message
                    component.set("v.bNoRecordsFound" , true);
                } 
            }
            else{
                alert('Error...');
            }
        });
        $A.enqueueAction(action);    
    },
    showToast : function(component, event, helper,title,type,time,message) {
        console.log('show toast');
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type" : type,
            "duration" : time,
            "message": message

        });
        toastEvent.fire();
    },
    getEmailTemplateHelper: function (component, event) {

        var action = component.get("c.getEmailTemaltes");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue() != null) {
                console.log('....');
                component.set("v.emailTemplateList", response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);

    },
    getfields: function(component, event, helper,objname) { 

        component.set('v.loaded', true);
        console.log('get fields');
        console.log({objname});
        var action = component.get("c.getAllFields");
        // var userObj=component.find("SobjectList").get("v.value");
        // action.setParams({
        //     "fld": userObj
        // });
        // Add callback behavior for when response is received
        var opts=[];
        action.setParams({
            "objname" : objname
        });
        action.setCallback(this, function(response) {

            //console.log({response});
            var state = response.getState();
            console.log(response.getReturnValue());
            if (state == "SUCCESS") {
                var allValues = response.getReturnValue();
                for (var i = 0; i < allValues.length; i++) {
                    var x = allValues[i].split(':::');
                    opts.push({
                        class: "optionClass",
                        label: x[0],
                        value: x[1]
                    });
            }
            component.set('v.loaded', false);
                component.find("FieldsList").set("v.options", opts);
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);
    },

    getPreview: function(component,event,helper,objname){

        component.set('v.loaded', true);
        var action = component.get("c.getPreview");
        var AllSelectedLeads = component.get("v.selectedLead");
        console.log({AllSelectedLeads});
        var recordid = AllSelectedLeads[0].Id;
        var mailB = component.get("v.emailbody");
        console.log({mailB});
        console.log({recordid});
        action.setParams({
            "recordId" : recordid,
            "MailBody" : mailB,
            "objname" : objname
        });
        action.setCallback(this, function (response) {
            console.log({response});
            var state = response.getState();
            console.log({state});
            if (state === "SUCCESS" && response.getReturnValue() != null) {
                var res = response.getReturnValue();
                console.log({res});
                component.set("v.PreviewBody",res);
                console.log({res});
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            component.set("v.loaded",false);
        });
        // Send action off to be executed
        $A.enqueueAction(action);
    },

    SendMailsHelper: function(component,event,helper,objname){
        var action = component.get("c.SendMailsMethod");
        var Lead = [];
        var selectedRec = component.get("v.selectedLead");
        for(var i = 0; i< selectedRec.length;i++){
            Lead.push(selectedRec[i].Id);
        }
        console.log({Lead});
        var Sub = component.get("v.subject");
        console.log({Sub});
        var mailB = component.get("v.emailbody");
        console.log({mailB});
        var File =  component.get("v.fileObj");
        console.log({File});
        var filename;
        var filetype;
        if(File != null){
            filename = File.name;
            filetype = File.type;
        }else{
            filename = '';
            filetype = '';
        }
        var fileBlob = component.get("v.fileBlob");
        console.log({fileBlob});
        // debugger;
        action.setParams({
            "IdList" : Lead,
            "Subject" : Sub,
            "MailBody" : mailB,
            "FileName" : filename,
            "FileType" : filetype,
            "FileBlob" : fileBlob,
            "objname" : objname
        });
        action.setCallback(this, function (response) {
            console.log({response});
            var state = response.getState();
            if (response.getReturnValue() == 'Emails Sent Successfully!!') {
                var res = response.getReturnValue();
                console.log({res});
                // alert('Emails Sent Successfully!!');
                helper.showToast(component,event,helper,"Success","Success",0,res);
                window.location.reload();
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);
    },   
    getSearchContact : function(component,event,getvalue){
        let selectedobj = component.get("v.selectedobjectname");
        var leadStatus = component.get("v.leadStatus");
        console.log({selectedobj});
        var action = component.get("c.getSearchValue");
        action.setParams({
            "objname" : selectedobj,
            "searchname" : getvalue,
            "leadSource" : leadStatus
        });
        action.setCallback(this, function(response) {
            console.log({response});
            var state = response.getState();
            console.log({state});
            if (state === "SUCCESS" && response.getReturnValue() != null) {
                var oRes = response.getReturnValue();
                console.log({oRes});
                if(oRes.length > 0){
                    component.set("v.bNoRecordsFound" , false);
                    // var selectedRecordFromEvent = component.get("v.ListOfSelectedRecord");
                    // console.log('selectedRecordFromEvent-->',selectedRecordFromEvent);
                    // if(selectedRecordFromEvent != null && selectedRecordFromEvent.length > 0){
                    //     for(var i=0; i < oRes.length; i++){
                    //         console.log('oRes[i].Id-->',oRes[i].objAccount.Id);
                    //         for(var j=0; j < selectedRecordFromEvent.length; j++){
                    //             console.log('selectedRecordFromEvent[j].Id-->',selectedRecordFromEvent[j].objAccount.Id);
                    //             if(oRes[i].objAccount.Id == selectedRecordFromEvent[j].objAccount.Id){
                    //                 oRes[i].isChecked = true;
                    //                 console.log('oRes[i].isChecked-->',oRes[i].isChecked);
                    //             }
                    //         }
                    //     }
                    // }

                    var selectedRecordFromEvent = component.get("v.ListOfSelectedRecord");
                    if (selectedRecordFromEvent && selectedRecordFromEvent.length) {
                        var selectedIds = new Set(selectedRecordFromEvent.map(function(item) {
                            return item.objAccount.Id;
                        }));
                        var selectedIndexes = {};
                        for (var j = 0; j < selectedRecordFromEvent.length; j++) {
                            selectedIndexes[selectedRecordFromEvent[j].objAccount.Id] = j;
                        }
                        for (var i = 0; i < oRes.length; i++) {
                            var objId = oRes[i].objAccount.Id;
                            if (selectedIds.has(objId)) {
                                oRes[i].isChecked = true;
                                console.log('oRes[i].isChecked-->', oRes[i].isChecked);
                                selectedRecordFromEvent[selectedIndexes[objId]].isChecked = true;
                            }
                        }
                    }

                    component.set('v.listOfAllAccounts', oRes);
                    console.log('Ores-->',oRes.length);
                    debugger;
                    var pageSize = component.get("v.pageSize");
                    var totalRecordsList = oRes;
                    var totalLength = totalRecordsList.length ;
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);                    
                    var PaginationLst = [];
                    for(var i=0; i < pageSize; i++){
                        if(component.get("v.listOfAllAccounts").length > i){
                            console.log('oRes-->',oRes[i]);
                            PaginationLst.push(oRes[i]);    
                        } 
                    }
                    console.log({PaginationLst});
                    component.set('v.PaginationList', PaginationLst);
                    component.set("v.selectedCount" , 0);
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));
                }else{
                    component.set("v.bNoRecordsFound" , true);
                }
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                console.log({errors});
            }
            
        });
        // Send action off to be executed
        $A.enqueueAction(action);
    },
    getPicklistValues: function(component, event) {
        var action = component.get("c.getLeadSourceFieldValue");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var fieldMap = [];
                for(var key in result){
                    fieldMap.push({key: key, value: result[key]});
                }
                component.set("v.fieldMap", fieldMap);
            }
        });
        $A.enqueueAction(action);
    },
})