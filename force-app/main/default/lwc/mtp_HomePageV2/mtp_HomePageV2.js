import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import { getRecord } from 'lightning/uiRecordApi';
// import homepage from '@salesforce/resourceUrl/homepage';
import course from '@salesforce/resourceUrl/course';
import timesheet from '@salesforce/resourceUrl/timesheet';
import leave from '@salesforce/resourceUrl/leave';
import calender from '@salesforce/resourceUrl/calender';
import arrow from '@salesforce/resourceUrl/arrow';

// import checkuser from '@salesforce/apex/TimesheetControllerV2.checkuser';

export default class Mtp_HomePageV2 extends NavigationMixin(LightningElement) {

    imgarrow = arrow;
    courseimg = course;
    timesheetimg = timesheet;
    leaveimg = leave;
    calenderimg = calender;
    @track username;
    userdetail;

    HideClass1 = "slds-show_medium";
    HideClass2 = "slds-Hide_medium";
    HideClass3 = "slds-show_medium";
    PreviousSection = "PROFILE";
    NextSection = "LEAVE";
    PreviousbtnVisibility = "slds-transition-show";
    NextbtnVisibility = "slds-transition-show";
    NaviconsClass="";

    // get imghome(){
    //     return `background-image:url(${homepage})`;
    // }

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD]
    }) wireuser({
        error,
        data
    }) {
        this.isSpinner = true;
        if (error) {
            this.error = error;
            this.isSpinner = false;
        } else if (data) {
            this.username = data.fields.Name.value;
            this.isSpinner = false;
        }
    }

    
    navigation(event){
        try{
            console.log({event});
            let name = event.currentTarget.dataset.name;
            console.log({name});
    
            var pageapiname;
            var urlValue = '/s/';
    
            if(name == "course"){
                pageapiname = 'Course__c';
                urlValue += 'course';
            }else if(name == "timesheet"){
                    pageapiname = 'Timesheet__c';
                    urlValue += 'timesheet';
            }else if(name == "leave"){
                pageapiname = 'Leave__c';
                urlValue += 'leave';
            }
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: pageapiname,
                    url: urlValue
                },
            });
        }
        catch(error){
            console.log('Error in navigation-->',{error});
        }
    }


// =====================>  Navigation Buttion Function  <=========================================

handlePreviousSection(){
    try{

        if(this.PreviousSection == "PROFILE" && this.NextSection == "LEAVE" ){
            this.HideClass1 = "slds-Hide_medium";
            this.HideClass2 = "slds-show_medium";

            this.NextSection = "TIMESHEET";
            this.PreviousbtnVisibility = "slds-transition-hide";

            // $(".PreviousSection").hide();
        } else if (this.PreviousSection == "TIMESHEET" ){
            this.HideClass2 = "slds-Hide_medium";
            this.HideClass3 = "slds-show_medium";
        
            this.PreviousSection = "PROFILE";
            this.NextSection = "LEAVE";
            this.NextbtnVisibility = "slds-transition-show"; 
            }    
    }
    catch(error){
        console.log('Error in handlePreviousSection-->',{error});
    }
    }

    handleNextSection(){
        try{

            if( this.PreviousSection == "PROFILE" && this.NextSection == "LEAVE" ){
                this.HideClass3 = "slds-Hide_medium";
                this.HideClass2 = "slds-show_medium";
                
                this.PreviousSection = "TIMESHEET";
                this.NextbtnVisibility = "slds-transition-hide";
    
            } else if (this.NextSection == "TIMESHEET" ){
                this.HideClass2 = "slds-Hide_medium";
                this.HideClass1 = "slds-show_medium";
                
                this.PreviousSection = "PROFILE";
                this.NextSection = "LEAVE";
                this.PreviousbtnVisibility = "slds-transition-show";
                // $(".PreviousSection").Show(); 
                }
        }
        catch(error){
            console.log('Error in handleNextSection-->',{error});
        }
    }


  
  boxClass = "";
  handleClick() {
    this.boxClass = "box";
  }



}