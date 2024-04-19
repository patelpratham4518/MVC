({
    doInit: function (component,event,helper) {
        helper.getProjectList(component,event,helper);
        helper.getEmployees(component,event,helper);
        helper.getClientList(component,event,helper);
        helper.getModuleList(component,event,helper);
        helper.getTaskList(component,event,helper);
    },
    
    assignedProject : function(component,event,helper){
      helper.assignedProjectHelper(component,event,helper);
    },
    
    removeEmployee : function(component,event,helper){
        var selectedAssignedEmpId = event.getSource().get("v.name");
        var action = component.get("c.revokeEmployee");
        action.setParams({
            assignedEmpId : selectedAssignedEmpId
        });
        action.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){
                // helper.assignedProjectHelper(component,event,helper);
                component.set("v.modalpopupAssignedProject",false);
                helper.showInfoToast();
            }
        });
        $A.enqueueAction(action);
    },
    
    addNewClient : function(component,event,helper){
        var clientName = component.find("clientName").get("v.value");
        var clientEmail = component.find("clientEmail").get("v.value");
        var clientPhone = component.find("clientPhone").get("v.value");
        var clientLocation = component.find("clientLocation").get("v.value");
        var clientCompany = component.find("clientCompany").get("v.value");
        var description = component.find("clientDescription").get("v.value");
        
        var displayMessage = '';
        
        if(clientName == ''){
            displayMessage = 'Please enter the Client Name.';
            helper.showErrorToast(component,event,displayMessage);
        }else if(clientEmail == ''){
            displayMessage = 'Please enter the Email Address.';
            helper.showErrorToast(component,event,displayMessage);
        }else{
            if(clientPhone == ''){
                clientPhone = 'NA';
            }
            if(clientLocation == ''){
                clientLocation = 'NA';
            }
            if(clientCompany == ''){
                clientCompany = 'NA';
            }
            if(description == undefined || description == ''){
                description = 'NA';
            }
            console.log('inside createNewClient ')
            var action = component.get("c.createNewClient");
            action.setParams({
                "clientName" : clientName,
                "clientEmail" : clientEmail,
                "clientPhone" : clientPhone,
                "clientLoc" : clientLocation,
                "company" : clientCompany,
                "description" : description
            });
            action.setCallback(this,function(response){
                if(response.getState() == "SUCCESS"){
                    if(response.getReturnValue()=="Success"){
                        displayMessage = 'New Client is added Successfully.'
                        helper.showSuccessToast(component,event,displayMessage);
                        helper.getClientList(component,event,helper);
                        helper.clearClientFieldshelper(component,event,helper);
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    assignedProjectToEmployee : function(component,event,helper){
      var selectedEmp = component.find("selectEmployeeToAssignId").get("v.value");
      var selectedRole = component.find("selectRoleToAssignId").get("v.value");
      var selectedProject = component.get("v.selectedGlobalproject");
      console.log(selectedEmp);
      console.log(selectedRole);
      console.log(selectedProject);
      var displayMessage = '';
      if(selectedEmp == ''){
          displayErrorMessage = 'Please Select the Employee.';
          helper.showErrorToast(component, event, displayMessage);
      }else if(selectedRole == ''){
          displayAlertMessage = 'Please Select the Role.';
          helper.showErrorToast(component, event, displayMessage);
      }else{
          var action = component.get("c.assignedEmployeeToProject");
          action.setParams({
              "projectName" : selectedProject,
              "empName" : selectedEmp,
              "role" : selectedRole
          });
          action.setCallback(this,function(response){
              if(response.getState()=="SUCCESS"){
                  console.log(response.getReturnValue());
                  if(response.getReturnValue()=="Success"){
                      displayMessage = 'Project is Assigned Successfully';
                      helper.showSuccessToast(component,event,displayMessage);
                      component.set("v.modalpopupAssignedProject",false);
                  }
              }
          });
          $A.enqueueAction(action);
      }
    },
    
    addNewProjectPopup : function(component,event,helper){
      component.set("v.modalpopupAddNewProject",true);  
    },
    
    addNewProject : function(component,event,helper){
      var projectName = component.find("projectNameId").get("v.value");
      var selectedClientName = component.find("selectClientId").get("v.value");
      var startDate = component.find("startDateId").get("v.value");
      var endDate = component.find("endDateId").get("v.value");
      var projectDescription = component.find("projectDescriptionId").get("v.value");
      
      var displayMessage = '';
      
      if(projectName == ''){
          displayMessage = 'Please enter the Project Name.';
          helper.showErrorToast(component, event, displayMessage);
      }else if(selectedClientName == ''){
          displayMessage = 'Please select the Client Name.';
          helper.showErrorToast(component, event, displayMessage);
      }else if(startDate == '' || startDate == null){
          displayMessage = 'Please enter the Start Date.';
          helper.showErrorToast(component, event, displayMessage);
      }else if(endDate == '' || endDate == null){
          displayMessage = 'Please enter the End Date.';   
          helper.showErrorToast(component, event, displayMessage);
      }else if(projectDescription == undefined || projectDescription==''){
          displayMessage = 'Please enter the Project Description in brief.';
          helper.showErrorToast(component,event,displayMessage);
      }else{
          var action = component.get("c.createNewProject");
          action.setParams({
              "projectName" : projectName,
              "clientName" : selectedClientName,
              "startDate" : startDate,
              "endDate" : endDate,
              "Description" : projectDescription
          });
          action.setCallback(this,function(response){
              if(response.getState()=="SUCCESS"){
                 if(response.getReturnValue()){
                     displayMessage = 'New Project is added Successfully';
                     component.set("v.modalpopupAddNewProject",false); 
                     helper.showSuccessToast(component,event,displayMessage);
                     helper.getProjectList(component,event,helper);
                 } 
              }else{
                  displayMessage = 'Something went wrong.';
                  helper.showErrorToast(component,event,displayMessage);
              }
          });
          $A.enqueueAction(action);
      } 
    },
    
    addNewModulePopup : function(component,event,helper){
        component.set("v.modalpopupAddNewModule",true);        
    },
    
    addNewTaskPopup : function(component,event,helper){
        alert('dsfsfd');
        component.set("v.modalpopupAddNewTask",true);
    },
    
    addNewModule : function(component,event,helper){
      var moduleName = component.find("moduleNameId").get("v.value");
      var projectName = component.find("selectProjectId").get("v.value");
      var moduleStartDate = component.find("moduleStartDateId").get("v.value");
      var moduleEndDate = component.find("moduleEndDateId").get("v.value");
      var description = component.find("moduleDescriptionId").get("v.value");
      console.log(moduleName);
      console.log(projectName);
      console.log(moduleStartDate);
      
      var displayMessage = '';
      
      if(moduleName == ''){
          displayMessage = 'Please enter the Module Name';
      }else if(projectName == ''){
          displayMessage = 'Please select the Project Name';
      }else if(moduleStartDate == '' || moduleStartDate == null){
          displayMessage = 'Please enter the Start Date';
      }else if(moduleEndDate == ''){
          displayMessage = 'Please enter the End Date';
      }else if(description == ''){
          displayMessage = 'Please enter the Project Description in brief.';
      }else{
          var action = component.get("c.createNewModule");
          action.setParams({
              
          });
          action.setCallback(this,function(response){
              
          });
          $A.enqueueAction(action);
      }
    },
    
    clearClientFields : function(component,event,helper){
        helper.clearClientFieldshelper(component,event,helper);
    },
    
    closeModel : function(component,event,helper){
        component.set("v.modalpopupAssignedProject",false);
        component.set("v.modalpopupAddNewProject",false);  
        component.set("v.modalpopupAddNewModule",false);  
    }
})