({
    doInit : function(component, event, helper) {
        // component.set('v.mycolumns', [            
        //     { label: 'Name', fieldName: 'Name', sortable: true,type: 'text'},
        //     { label: 'Phone', fieldName:'Phone', sortable: true, type: 'number'},
        //     { label: 'Email', fieldName: 'Email', sortable: true,type: 'text'}            
        // ]);
        helper.toggleThreeAndOneSteps(component);
        component.set("v.progressIndicatorFlag", "step1");
        // helper.getAllLeads(component,event,helper);
        helper.getEmailTemplateHelper(component,event);
        // helper.getfields(component,event,helper);


        
    },
    goToStepTwo : function(component, event, helper) {

        var selectedobj = component.get("v.selectedValue");

        if(component.get("v.ListOfSelectedRecord") != null){
            component.set("v.ListOfSelectedRecord", []);
        }

        console.log({selectedobj});
        if (selectedobj == 'Lead') {
            helper.getPicklistValues(component, event);
            component.set("v.showleadfilter", true);
        } else {
            component.set("v.showleadfilter", false);
        }
        if(selectedobj != 'none'){
            component.set("v.selectedobjectname",selectedobj);
            helper.getfields(component,event,helper,selectedobj);
            helper.getAllLeads(component,event,helper,selectedobj);
            helper.toggleOneAndTwoSteps(component);
            component.set("v.progressIndicatorFlag", "step2");
        }else{
            // alert('Please Select Object');
            helper.showToast(component,event,helper,"Error","Error",0,"Please Select Object!");
        }
    },
    goToStepThree : function(component, event, helper) {        
        var allRecords = component.get("v.ListOfSelectedRecord");
        console.log({allRecords});
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedRecords.push(allRecords[i].objAccount);
            }
        }
        let isTeam = component.get("v.showTeam");
        if (isTeam) {
            let selectedTeamId = component.get("v.selectedTeam");
            console.log({selectedTeamId});
            if (selectedTeamId) {
                helper.toggleTwoAndThreeSteps(component);
                component.set("v.progressIndicatorFlag", "step3");
            } else {
                helper.showToast(component,event,helper,"Error","Error",0,"Please Select atleast one Team to send mail!");
            }
        } else {
            if(selectedRecords.length > 0){
                helper.toggleTwoAndThreeSteps(component);
                component.set("v.progressIndicatorFlag", "step3");
                debugger;
                component.set("v.selectedLead",selectedRecords);
                console.log(component.get("v.selectedLead"));
            }else{
                helper.showToast(component,event,helper,"Error","Error",0,"Please Select atleast one record to send mail!");
            }
        }
    },
    goToStepFour : function(component, event, helper) {
        var subject = component.get("v.subject");
        var mailBody = component.get("v.emailbody");

        if(subject == ""){
            // alert('Please Fill out subject to send mail!');
            helper.showToast(component,event,helper,"Error","Error",0,"Please fill out subject to send mail!");
        }else if(mailBody == ""){
            // alert('Please Fill out body to send mail!');
            helper.showToast(component,event,helper,"Error","Error",0,"Please fill out body to send mail!");
        }else{

            let isTeam = component.get("v.showTeam");
            if (isTeam) {
                let selectedTeamId = component.get("v.selectedTeam");
                console.log({selectedTeamId});
                // Need to Add Logic
                helper.toggleThreeAndFourSteps(component);
                component.set("v.progressIndicatorFlag", "step4");
            } else {
                var selectedobj = component.get("v.selectedValue");
                console.log({selectedobj});
                helper.getPreview(component,event,helper,selectedobj);
                helper.toggleThreeAndFourSteps(component);
                component.set("v.progressIndicatorFlag", "step4");   
            }
        }
    },
    goBackToStepOne : function(component, event, helper) {
        helper.toggleOneAndTwoSteps(component);
        component.set("v.progressIndicatorFlag", "step1");
    },
    goBackToStepTwo : function(component, event, helper) {
        helper.toggleTwoAndThreeSteps(component);
        component.set("v.progressIndicatorFlag", "step2");
    },
    goBackToStepThree : function(component, event, helper) {
        helper.toggleThreeAndFourSteps(component);
        component.set("v.progressIndicatorFlag", "step3");
    },
    navigation: function(component, event, helper) {
        var sObjectList = component.get("v.listOfAllAccounts");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var whichBtn = event.getSource().get("v.name");
        console.log({pageSize});
        console.log({start});
        console.log({end});
        // check if whichBtn value is 'next' then call 'next' helper method
        if (whichBtn == 'next') {
            component.set("v.currentPage", component.get("v.currentPage") + 1);
            helper.next(component, event, sObjectList, end, start, pageSize);
        }
        // check if whichBtn value is 'previous' then call 'previous' helper method
        else if (whichBtn == 'previous') {
            component.set("v.currentPage", component.get("v.currentPage") - 1);
            helper.previous(component, event, sObjectList, end, start, pageSize);
        }
    },
    
    selectAllCheckbox: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var updatedAllRecords = [];
        var updatedPaginationList = [];
        var selectedRecordIdList = [];
        var listOfAllAccounts = component.get("v.listOfAllAccounts");
        var PaginationList = component.get("v.PaginationList");
        // play a for loop on all records list 
        for (var i = 0; i < listOfAllAccounts.length; i++) {
            // check if header checkbox is 'true' then update all checkbox with true and update selected records count
            // else update all records with false and set selectedCount with 0  
            if (selectedHeaderCheck == true) {
                listOfAllAccounts[i].isChecked = true;
                selectedRecordIdList.push(listOfAllAccounts[i]);
                console.log({selectedRecordIdList});
                // add all the unique Id's in selectedRecordIdList attribute.
                component.set("v.selectedCount", selectedRecordIdList.length);
            } else {
                listOfAllAccounts[i].isChecked = false;
                component.set("v.selectedCount", 0);
            }
            updatedAllRecords.push(listOfAllAccounts[i]);
        }
        // update the checkbox for 'PaginationList' based on header checbox 
        for (var i = 0; i < PaginationList.length; i++) {
            if (selectedHeaderCheck == true) {
                PaginationList[i].isChecked = true;
            } else {
                PaginationList[i].isChecked = false;
            }
            updatedPaginationList.push(PaginationList[i]);
        }
        component.set("v.ListOfSelectedRecord", selectedRecordIdList);
        component.set("v.listOfAllAccounts", updatedAllRecords);
        component.set("v.PaginationList", updatedPaginationList);
    },
    
    checkboxSelect: function(component, event, helper) {
        // on each checkbox selection update the selected record count 
        var selectedRecList = component.get("v.ListOfSelectedRecord");
        var selectedRec = event.getSource().get("v.value");
        var selectedRecId = event.getSource().get("v.text");
        var allaccountList = component.get("v.listOfAllAccounts");
        var getSelectedNumber = component.get("v.selectedCount");

        if (selectedRec == true) {
            getSelectedNumber++;
            for (var i = 0; i < allaccountList.length; i++) {
                if (allaccountList[i].objAccount.Id == selectedRecId) {
                    allaccountList[i].isChecked = selectedRec;
                    selectedRecList.push(allaccountList[i]);
                }
            }
        } else {
            getSelectedNumber--;
            component.find("selectAllId").set("v.value", false);
            for (var i = 0; i < selectedRecList.length; i++) {
                if (selectedRecList[i].objAccount.Id == selectedRecId) {
                    selectedRecList.splice(i, 1);
                }
            }
        }
        component.set("v.ListOfSelectedRecord", selectedRecList);
        component.set("v.selectedCount", selectedRecList);
        if (getSelectedNumber == component.get("v.totalRecordsCount")) {
            component.find("selectAllId").set("v.value", true);
        }
    },
    
    getSelectedRecords: function(component, event, helper) {
        var allRecords = component.get("v.listOfAllAccounts");
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedRecords.push(allRecords[i].objAccount);
            }
        }
        alert(JSON.stringify(selectedRecords));
    },

    onSelectEmailTemplate: function (component, event, helper) {
        var emailTempId = event.target.value;
        var emailbody = '';
        var emailSubject = '';
        component.set("v.templateIDs", emailTempId);
        if (emailTempId != null && emailTempId != '' && emailTempId != 'undefined') {
            var emailTemplateList = component.get("v.emailTemplateList");
            emailTemplateList.forEach(function (element) {
                if (element.emailTemplateId == emailTempId && element.emailbody != null) {
                    emailbody = element.emailbody;
                    emailSubject = element.emailSubject;
                }
            });
        }
        component.set("v.emailbody", emailbody);
        component.set("v.subject", emailSubject);
    },

    AddfieldToMailBody: function(component,event,helper){
        var valueOfField = component.find("FieldsList").get("v.value");
        var sobj = component.get("{!v.selectedValue}");
        if(valueOfField != ""){
            var SubjectValue = component.get("v.emailbody");
            var AddField = '{!'+sobj+'.'+valueOfField+'}';
            SubjectValue += AddField;
            component.set("v.emailbody",SubjectValue);
        }else{
            // alert('Please Select atleast one field to add into body!');
            helper.showToast(component,event,helper,"Error","Error",0,"Please Select atleast one field to add into body!");
        }
    },

    SendMails: function(Component,event,helper){
        var selectedobj = Component.get("{!v.selectedValue}");
        console.log({selectedobj});
        helper.SendMailsHelper(Component,event,helper,selectedobj);
    },
    fileDetails: function(component, event, helper){
		// This will contain the List of File uploaded data and status.
        console.log('In the File Details');
		var uploadFile = event.getSource().get("v.files");
		var self = this;
		var file = uploadFile[0]; // getting the first file, loop for multiple files
		var reader = new FileReader();
		reader.onload =  $A.getCallback(function() {
			var dataURL = reader.result;
            console.log({dataURL});
			var base64 = 'base64,';
			var dataStart = dataURL.indexOf(base64) + base64.length;
			dataURL= dataURL.substring(dataStart);
            console.log({dataURL});
            component.set("v.fileBlob",dataURL);
            component.set("v.fileObj",file);
            var fileBlob = component.get("v.fileBlob");
            var fileObj = component.get("v.fileObj");
            console.log({fileBlob});
            console.log({fileObj});
            component.set("v.bool",true);
			// helper.upload(component, file, dataURL);
		});
		reader.readAsDataURL(file);
        console.log({reader});
	},    
    searchContact: function(component, event, helper){
        let searchval = component.get("v.searchval");
        helper.getSearchContact(component,event,searchval);
    },
    isTeam: function(component, event, helper){
        var checkCmp = component.find("teamcheckbox").get("v.value");
        console.log({checkCmp});
        if(checkCmp) {
            component.set("v.showTeam",true);
            helper.getTeamList(component,event);
        } else {
            component.set("v.showTeam",false);
        }
    },
    selectTeam: function(component, event, helper){
        let id = component.find("teamid").get("v.title");
        component.set("v.selectedTeam",id);
        let name = component.find("teamid").get("v.name");
        component.set("v.selectedTeamName",name);
    },
    handlefilter: function(component, event, helper){
        console.log('Handle Filter');
        let searchval;
        if (component.get("v.searchval") == undefined || component.get("v.searchval") == null || component.get("v.searchval") == '') {
            searchval = '';
        }
        else {
            searchval = component.get("v.searchval");
        }
        helper.getSearchContact(component,event,searchval);
    },
})