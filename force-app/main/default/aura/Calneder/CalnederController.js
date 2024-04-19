({
	 afterScriptsLoaded: function(cmp,evt,helper){
         
         helper.fetchCalenderEvents(cmp);
        
    },
    
     handleClick : function(component, event, helper){ 
      
         var buttonstate = component.get("v.buttonstate");
         alert(buttonstate);
//          component.set("v.buttonstate",!buttonstate);
//          if(!buttonstate){
//           $("#listcalendar").show();
//          $("#calendar").hide();
//          $('#listcalendar').fullCalendar({
//         	defaultView: 'listWeek',
//              listDayFormat : true,
//              events : component.get("v.Objectlist")
// 		});
        
//          }
//          else{
//               $("#calendar").show();
//           $("#listcalendar").hide();   
//              helper.fetchCalenderEvents(component);
//          }
        
    },
    openModel: function(component, event, helper) {
      // for Display Model,set the "isOpen" attribute to "true"
      component.set("v.dialog", true);
   },
 
   closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
      component.set("v.dialog", false);
   },

})