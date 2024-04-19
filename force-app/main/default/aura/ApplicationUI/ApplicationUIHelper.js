({
  MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB
  CHUNK_SIZE: 750000,

  doInit: function (component, event, helper) {
    var action = component.get("c.getPostingName");
    action.setParams({
      posting: component.get("v.postingId")
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      console.log(response.getReturnValue() + " Return Value");
      if (state === "SUCCESS") {
        var x = response.getReturnValue();
        console.log(x.On_Off__c);
        if (x.On_Off__c == false) {
          component.set("v.spinner", false);
          component.set("v.JobStatus", false);
        } else {
          component.set("v.JobStatus", true);
          component.set("v.postingName", response.getReturnValue().Job_Name__c);
          component.set("v.spinner", false);
        }
      } else {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            // log the error passed in to AuraHandledException
            console.log("Error message: " + errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },

  submit: function (component, event, helper) {
    if (component.get("v.FirstName") == "") {
      alert("Please fill firstname");
    }

    if (component.get("v.fileName") != "No File Selected..") {
      var fileInput = component.find("fileId").get("v.files");
      var file = fileInput[0];

      /*   if (file.type != "application/pdf") {
                component.set("v.fileName", 'Only pdf allowed');
                component.set("v.spinner", false);
                alert("Only pdf file allowed");
                return;
            }  */
      if (file.size > this.MAX_FILE_SIZE) {
        // component.set("v.showLoadingSpinner", false);
        component.set(
          "v.fileName",
          "Alert : File size cannot exceed " +
            this.MAX_FILE_SIZE +
            " bytes.\n" +
            " Selected file size: " +
            file.size
        );
        component.set("v.spinner", false);
        return;
      }
      var objFileReader = new FileReader();
      objFileReader.onload = $A.getCallback(function () {
        var fileContents = objFileReader.result;
        var base64 = "base64,";
        var dataStart = fileContents.indexOf(base64) + base64.length;

        fileContents = fileContents.substring(dataStart);
        helper.uploadProcess(component, file, fileContents, event, helper);
      });

      objFileReader.readAsDataURL(file);
    }
  },

  uploadProcess: function (component, file, fileContents, event, helper) {
    var startPosition = 0;
    var endPosition = Math.min(
      fileContents.length,
      startPosition + this.CHUNK_SIZE
    );
    helper.uploadInChunk(
      component,
      file,
      fileContents,
      startPosition,
      endPosition,
      ""
    );
  },

  uploadInChunk: function (
    component,
    file,
    fileContents,
    startPosition,
    endPosition,
    attachId
  ) {
    var getchunk = fileContents.substring(startPosition, endPosition);
    console.log(component.get("v.FE"));

    //  var selectedPicklistValue= component.find("statusPicklist").get("v.value");

    var action = component.get("c.submitContact");
    action.setParams({
      // parentId: component.get("v.parentId"),
      fileName: file.name,
      base64Data: encodeURIComponent(getchunk),
      contentType: file.type,
      FirstName: component.get("v.FirstName"),
      LastName: component.get("v.LastName"),
      Email: component.get("v.Email"),
      Gender: component.get("v.Gender"),
      Mobile: component.get("v.Mobile"),
      Experience: component.get("v.Experience"),
      jobPosting: component.get("v.postingId"),
      FreshorExp: component.get("v.FE"),
      currentcity: component.get("v.currentcity"),
      state: component.get("v.state"),
      permanentcity: component.get("v.permanentcity"),
      percity: component.get("v.percity"),
      relocate: component.get("v.relocate"),
      dateOfBirth: component.get("v.dateOfBirth"),
      Month: component.get("v.Month")
    });
    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state == "SUCCESS") {
        console.log(response.getReturnValue());

        if (response.getReturnValue() == "true") {
          component.set("v.applied", response.getReturnValue());
          component.set("v.spinner", false);
          component.set("v.emailerror", true);
        }
        if (response.getReturnValue() == "email") {
          component.set("v.applied", true);
          component.set("v.emailerror", false);
          component.set("v.spinner", false);
        }
      } else {
        component.set("v.spinner", false);
      }
    });
    $A.enqueueAction(action);
  }
});