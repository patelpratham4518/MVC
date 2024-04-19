({
    /* doInit: function(component, event, helper) {
         var url_string = window.location.href;
         var url = new URL(url_string);
         var urlId = url.searchParams.get("Id");
         if (urlId == '') {
             component.set("v.error", false);
         } else {
             component.set("v.postingId", urlId);
             helper.doInit(component, event, helper);
         }
 
     },  */
 
     doInit: function(component, event, helper) {
         var url_string = window.location.href;
         var url = new URL(url_string);
         var urlId = url.searchParams.get("Id");
         console.log({urlId});
         if (urlId == '') {
             component.set("v.error", false);
         } else {
             component.set("v.postingId", urlId);
             helper.doInit(component, event, helper);
         }
 
     },
 
     submit: function(component, event, helper) {
         
         try {
             component.set("v.spinner", true);
                // component.set("v.isdisabled",true);
 
         var validateSelect;
         var validFile = false;
         if (component.find("values") != undefined) {
             validateSelect = component.find("values").reduce(function(validSoFar, inputCmp) {
                 inputCmp.showHelpMessageIfInvalid();
                 return validSoFar && inputCmp.get('v.validity').valid;
             }, true);
         }
         
         if (component.get("v.fileName") != 'No File Selected..') {
             validFile = true;
         } else {
             validFile = false;
             alert("Please Upload File");
             component.set("v.spinner", false);
             return;
         }
         if (validateSelect && validFile) {
             component.set("v.dis","true");
             helper.submit(component, event, helper);
         } else {
             component.set("v.spinner", false);
         }
         } catch (error) {
             console.log('Catch the error on Submit ' + error);
         }
     },
 
     change: function(component, event, helper) {
         var inp = component.get("v.FE");
         var Email = component.get("v.Email");
         var trimEmail = Email.trim();
         var Mobile = component.get("v.Mobile");
         console.log(Mobile);
         var trimMobile = Mobile.trim();
         component.set("v.Mobile",trimMobile);
         console.log(trimMobile);
         component.set("v.Email",trimEmail);
         console.log(trimEmail);
         console.log(Email);
         console.log(inp);
 
         if (inp == "Experienced") {
 
             component.set("v.exp", true);
         }
         if (inp == "0" || inp == "Fresher") {
 
             component.set("v.exp", false);
         }
         
     },

     handleFilesChange: function(component, event, helper) {
         var fileName = 'No File Selected..';
         if (event.getSource().get("v.files").length > 0) {
             fileName = event.getSource().get("v.files")[0]['name'];
         }
         component.set("v.fileName", fileName);
     },
     
     oselect: function(component, event, helper) {
        
         var pecity = component.get("v.permanentcity");
         console.log(pecity);
         var city =  component.find('values12').get('v.value');
        //  var city =  component.find('values').get('v.value');
          var city1 = city.toLowerCase();
         var city2 = city.toUpperCase();
         console.log({city1});
         console.log(city);
         
        
   /*  if (pecity == "Yes"){
         if(city == "Ahmedabad" || city == city1 ||city == city2){
             component.set("v.ccity", false);
             component.set("v.pcity", false);
             component.set("v.peecity", false);
         } 
         else{
             component.set("v.ccity", false);
             component.set("v.pcity", true);
             component.set("v.peecity", false);
         }
     }       
     
     if(pecity == "No"){
         if(city == "Ahmedabad" || city == city1 ||city == city2){
             component.set("v.ccity", false);
             component.set("v.pcity", false);
             component.set("v.peecity", true);
         } 
         else{
         component.set("v.ccity", true);
         component.set("v.pcity", false);
         component.set("v.peecity", false);
         }
     }  */
    
     if(city == "Ahmedabad" || city == "ahmedabad" || city=="AHMEDABAD"){
     if (pecity == "Yes"){
             component.set("v.ccity", false);
             component.set("v.pcity", false);
             component.set("v.peecity", false);
         } 
         else{
             component.set("v.ccity", false);
             component.set("v.pcity", false);
             component.set("v.peecity", true);
         }
     }       
     
     else{
         if (pecity == "Yes"){
             component.set("v.ccity", false);
             component.set("v.pcity", true);
             component.set("v.peecity", false);
         } 
         else{
         component.set("v.ccity", true);
         component.set("v.pcity", false);
         component.set("v.peecity", false);
         }
     } 
  
 },
 
   
 })