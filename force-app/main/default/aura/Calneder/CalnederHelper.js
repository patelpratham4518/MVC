({
	loadDataToCalendar :function(component,data){  
        //Find Current date for default date
        var d = new Date();
        var month = d.getMonth()+1;
        var day = d.getDate();
        var currentDate = d.getFullYear() + '/' +
            (month<10 ? '0' : '') + month + '/' +
            (day<10 ? '0' : '') + day;
         
        var self = this;
        $('#calendar').fullCalendar({
            header: {
                left: 'prev,next today',
                center: 'title',
                right: 'month,basicWeek,basicDay'
            },
            selectable : true,
            defaultDate: currentDate,
            editable: true,
            eventLimit: true,
            events:data,
            dragScroll : true,
             droppable: true,
            weekNumbers : true,

          eventDrop: function(event, delta, revertFunc) {
        
            alert(event.title + " was dropped on " + event.start.format());
        
            if (!confirm("Are you sure about this change?")) {
              revertFunc();
            }
              else{
                  var eventid = event.id;
                  var eventdate = event.start.format();
                  self.editEvent(component,eventid,eventdate);
              }
        
          },
            eventClick: function(event, jsEvent, view) {
           
              var editRecordEvent = $A.get("e.force:editRecord");
              editRecordEvent.setParams({
              "recordId": event.id
           });
           editRecordEvent.fire();
          },
            dayClick :function(date, jsEvent, view) {
              
                var datelist = date.format().toString().split('-');
                var datetime = new Date(datelist[0],parseInt(datelist[1])-1,parseInt(datelist[2])+1,0,0,0,0);
                var createRecordEvent = $A.get("e.force:createRecord");
             component.set("v.dialog",true);
                createRecordEvent.setParams({
                    "entityApiName": "Event",
                    "defaultFieldValues": {
                    'StartDateTime' :  datetime
                    
                }
             });
        createRecordEvent.fire();
          },
            
            eventMouseover : function(event, jsEvent, view) {
            
          }
    });
    },
       
    addHolidayToCalender : function(component,events) {
        var josnDataArray = [];
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        
        for(var i = 0;i < events.length;i++){
            var startdate = $A.localizationService.formatDate(events[i].Date__c);
            var dayName = 'WeekDay';
            
            josnDataArray.push({
                'title':dayName,
                'start':startdate,
                'end':startdate,
                'id':events[i].Hours__c
            });
        }
        
        // for(var i = 0;i < events.length;i++){
        //     var startdate = $A.localizationService.formatDate(events[i].Date__c);
        //     var dayName = 'WeekDay';
            
        //     josnDataArray.push({
        //         'title':events[i].Hours_Minutes__c + ' Hours',
        //         'start':startdate,
        //         'end':startdate,
        //         'id':events[i].Hours__c + startdate
        //     });
        // }
        
        return josnDataArray;
    },
    
    formatFullCalendarData : function(component,events) {
        var josnDataArray = [];
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        
        for(var i = 0;i < events.length;i++){
            var startdate = $A.localizationService.formatDate(events[i].Date__c);
            var dayName = 'WeekDay';
            
            josnDataArray.push({
                'title':events[i].Hours_Minutes__c + ' Hours',
                'start':startdate,
                'end':startdate,
                'id':events[i].Hours_Minutes__c + startdate
            });
        }
        
        return josnDataArray;
    },
     
    fetchCalenderEvents : function(component) {
         var action=component.get("c.getAllEvents");
       
         action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data= response.getReturnValue();
                var josnArrHours = this.formatFullCalendarData(component,response.getReturnValue());
                var josnArrHolidays = this.addHolidayToCalender(component,response.getReturnValue());
                // var josnArr = josnArrHours;
                    // josnArr = josnArrHolidays;
                this.loadDataToCalendar(component,josnArrHours);
                this.loadDataToCalendar(component,josnArrHolidays);
                component.set("v.Holidaylist",josnArrHours);
                component.set("v.Holidaylist",josnArrHolidays);
            } else if (state === "ERROR") {
                                 
            }
        });
        
        $A.enqueueAction(action);
       
    }, 
    // fetchCalender : function(component) {
    //      var action=component.get("c.getAllHoliday");
       
    //      action.setCallback(this, function (response) {
    //         var state = response.getState();
    //         if (state === "SUCCESS") {
    //             var data= response.getReturnValue();
    //             var josnArrHolidays = this.addHolidayToCalender(component,response.getReturnValue());
    //             var josnArr = josnArrHolidays;

    //             this.loadDataToCalendar(component,josnArrHolidays);
    //             component.set("v.Holidaylist",josnArr);
           
    //         } else if (state === "ERROR") {
                                 
    //         }
    //     });
        
    //     $A.enqueueAction(action);
       
    // }, 
    
    editEvent : function(component,eventid,eventdate){
         var action=component.get("c.updateEvent");

         action.setParams({ eventid : eventid ,
                           eventdate : eventdate});

         action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            
           
            } else if (state === "ERROR") {
                                 
            }
        });
        
        $A.enqueueAction(action);

    }
})