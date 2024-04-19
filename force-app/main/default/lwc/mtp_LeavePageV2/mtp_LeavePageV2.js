import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import Leave from '@salesforce/schema/Leave__c';
import Start_date from '@salesforce/schema/Leave__c.Start_Date__c';
import End_date from '@salesforce/schema/Leave__c.End_Date__c';
import Day_Type from '@salesforce/schema/Leave__c.Day__c';
import Leave_Type from '@salesforce/schema/Leave__c.Leave_Type__c';
import Reason from '@salesforce/schema/Leave__c.Reason__c';

import mtp_LeavePageBG from '@salesforce/resourceUrl/mtp_LeavePageBG';
import course from '@salesforce/resourceUrl/course';
import timesheet from '@salesforce/resourceUrl/timesheet';
import leave from '@salesforce/resourceUrl/leave';
import calender from '@salesforce/resourceUrl/calender';
import arrow from '@salesforce/resourceUrl/arrow';
import USER_ID from '@salesforce/user/Id';
import middleflight from '@salesforce/resourceUrl/mtp_leaveflighticon';
import { getRecord } from 'lightning/uiRecordApi';


// import Start_Date from '@salesforce/schema/Leave__c.Start_Date__c';

import getUserType from '@salesforce/apex/LeaveControllerV2.getUserType';
import getFieldSet from '@salesforce/apex/LeaveControllerV2.getFieldSet';
// import GetMentorName from '@salesforce/apex/LeaveControllerV2.GetMentorName';
import allLeavesList from '@salesforce/apex/LeaveControllerV2.allLeavesList';
import getDaytypePicklist from '@salesforce/apex/LeaveControllerV2.getDaytypePicklist';
import getLeavetypePicklist from '@salesforce/apex/LeaveControllerV2.getLeavetypePicklist';
import getOrgDate from '@salesforce/apex/LeaveControllerV2.getOrgDate';
import SAVELeave from '@salesforce/apex/LeaveControllerV2.SAVELeave';
import DeleteLeaves from '@salesforce/apex/LeaveControllerV2.DeleteLeaves';
import SetLeaveTypePicklist from '@salesforce/apex/LeaveControllerV2.SetLeaveTypePicklist'; //
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import getFieldSet from '@salesforce/apex/TimesheetController.getFieldSet';

export default class Mtp_LeavePage extends NavigationMixin(LightningElement) {

    @api recordId;
    @track username;
    @track todayDate;
    Start_date = Start_date;
    End_date = End_date;
    Day_Type = Day_Type;
    Leave_Type = Leave_Type;
    Reason = Reason;
    recordid ;
    
    Start_Date__c;
    End_Date__c;
    Day__c;
    Leave_Type__c;
    Reason__c;
    @track inputFieldValues = {};

    dataname = 'PendingLeaves';
    @track DatepickerDate;
    imgarrow = arrow;
    courseimg = course;
    timesheetimg = timesheet;
    leaveimg = leave;
    calenderimg = calender;
    flighticon = middleflight;
   @track userType;                         // Store the type of User (Mentor Or Trainee)
    isSpinner = false;        
    ShowMentorName = false;                 //To Show Mentor Name 
    ShowApplyForLeave = false;              // To Display Aplly for Leave Button In case on Trainee
    ShowLeaveList = true;                  // To Show-Hide Leave List 
    ShowLeaveListInt = 0;                   // Use With Leavelist Variable For Logical Purpose
    ShowIllustration = false;                // To Show-Hide Aniamtion/Illutration
    ShowDELETEbtn = false;         
    ShowLeaveDetailPopup = false;           // to Show-Hide Leave Detail Popup (ModalBox)
    ShowDeleteAlertPopup = false;
    @track mentor = false;                  // To check if Logged in USer is Mentor or not
    @track trainee;
    @track DayTypePicklist = [];
    @track LeaveTypePicklist = [];
    lvt_type_color;                         // To change the Class Name For Leave Status Label (Geern--> Approve. red-->Rejected oranhe-->Pending)
    LeaveStatus;                            //  TO Change Leave list Header Dynamically
    objectName = 'Leave__c';
    fieldSetName = 'ApplyForLeaveModalBox';
    @track fields = [];
    @track projects = [];
    @track userId = USER_ID;
    @track traineeList =[];                     // Store All The Trainee Accosiaated With Logged in Mentor(Contact)
    @track selectedTrainee;                     // Store Seleced Trainee Id Based On Combobox And Passing to Apex Class
    @track mentorName;
    @track LeaveUpdateId;                   // Store The LeaveId Which We are Going To Approve or Rejecte (Update) And Passing to Apex Class
    @track TotalLeaves;    
    @track LeaveDetails = [];
    @track SelectedYearValue = '0000';                             // Store Value OF Month on Month Change Event
    @track years = [];                                             //Store Object Of Array For Year Picklist
    @track SelectedMonth = '0';                                  // Store Value OF Month on Month Change Event
    // @track Months = [];
    @track Months = [                                            // Generate And Store Object Of Array For Month Picklist
            { label: 'All Month', value: '0'},
            { label: 'Jan', value: '1'},
            { label: 'Feb', value: '2'},
            { label: 'Mar', value: '3'},
            { label: 'Apr', value: '4'},
            { label: 'May', value: '5'},
            { label: 'Jun', value: '6'},
            { label: 'Jul', value: '7'},
            { label: 'Aug', value: '8'},
            { label: 'Sep', value: '9'},
            { label: 'Oct', value: '10'},
            { label: 'Nov', value: '11'},
            { label: 'Dec', value: '12'},
        ];
    UtilityIcon;                             
    Lev_Name;
    Lev_DayType;
    Lev_StartDay;
    Lev_EndDay;
    Lev_Reason;
    Lev_Id;
    Lev_Status;
    Lev_LeaveType;
    get imghome() {
        return `background-image:url(${mtp_LeavePageBG})`;
    }


    connectedCallback(){
       
            this.isSpinner = true;
                setTimeout(() => {
                    this.isSpinner = false; 
                }, 1000);
        
        this.getOrgDate();
        // this.getFieldValueMethod();
        // this.getTraineeDetail();
        this.UserTypeChecking();
        this.SetYEarPicklistValues();
        this.GetDayTypePicklistValue();
        this.GetLeaveTypePicklistValue();
    }


    getOrgDate(){
        getOrgDate()
        .then(result =>{
            this.todayDate = result;
            this.DatepickerDate = result;
        })
        .catch(error =>{
            console.log('error : ',error);
        })
    }


    UserTypeChecking(){
        try{
            this.isSpinner = true;
        getUserType()
        .then(result =>{
            this.userType = result;
            this.getLeavesListForAll(this.dataname);
            if(this.userType == 'Senior Developer'){
                this.mentor = true;
                this.ShowMentorName = false;
            } 
            this.isSpinner = false;
        })
        .catch(error =>{
            console.log(error);
            this.isSpinner = false;
        })
    }
    catch(error){
        console.log('Error in UserTypeChecking-->',{error});
    }
    }


    // getFieldValueMethod(){
    //     try{
    //         getFieldSet({objectName: this.objectName, fieldSetName: this.fieldSetName})
    //         .then(result => {
    //             this.fields = JSON.parse(result);
    //             if(result.lenth != 0){
    //                 // this.GetMentorNameMethod();
    //                 this.ShowMentorName = true;
    //             }
                
    //         })
    //         .catch(error => {
    //             this.dispatchEvent(
    //                 new ShowToastEvent({
    //                     title: 'Error loading form',
    //                     message: error.body.message,
    //                     variant: 'error',
    //                 }),
    //             );
    //         }); 

    //     }
    //     catch(error){
    //         console.log('Error in getFieldValueMethod-->',{error});
    //     }     
    // }

    GetDayTypePicklistValue(){
        try{
            this.isSpinner = true;
            getDaytypePicklist()
            .then(result =>{
                this.DayTypePicklist = result.map((item) => Object.assign({}, item, { label: item, value: item }));
                this.isSpinner = false;
            })
            .catch(error =>{
                console.log('error : ',error);
                this.isSpinner = false;
            })

        }
        catch(error){
            console.log('Error in GetDayTypePicklistValue : ',error);
        }
    }
    GetLeaveTypePicklistValue(){
        try{
            this.isSpinner = true;
            getLeavetypePicklist()
            .then(result =>{
                this.LeaveTypePicklist = result.map((item) => Object.assign({}, item, { label: item, value: item }));
                this.isSpinner = false;
            })
            .catch(error =>{
                console.log('error : ',error);
                this.isSpinner = false;
            })

        }
        catch(error){
            console.log('Error in GetLeaveTypePicklistValue : ',error);
        }
    }
    handleApply(){
        try{
            
        this.Start_Date__c = this.template.querySelector('[data-id = "Start_Date__c"]').value;
        this.End_Date__c = this.template.querySelector('[data-id = "End_Date__c"]').value;
        this.Day__c = this.template.querySelector('[data-id = "Day__c"]').value;
        this.Leave_Type__c = this.template.querySelector('[data-id = "Leave_Type__c"]').value;
        this.Reason__c = this.template.querySelector('[data-id = "Reason__c"]').value;

        this.inputFieldValues.Start_Date__c = this.Start_Date__c;
        this.inputFieldValues.End_Date__c = this.End_Date__c;
        this.inputFieldValues.Day__c = this.Day__c;
        this.inputFieldValues.Leave_Type__c  = this.Leave_Type__c;
        this.inputFieldValues.Reason__c = this.Reason__c;

        if(this.Start_Date__c == '' || this.Start_Date__c == null || this.Start_Date__c == undefined){
            this.template.querySelector('c-mtp_-toast-message').showToast('error', 'Please Select Start Date', 3000);
        }
        else if(this.Start_Date__c < this.todayDate){
            this.template.querySelector('c-mtp_-toast-message').showToast('error', 'Please Select Valid Start Date', 3000);
        }
        else if(this.End_Date__c == '' || this.End_Date__c == null || this.End_Date__c == undefined){
            this.template.querySelector('c-mtp_-toast-message').showToast('error', 'Please Select End Date', 3000);
        }
        else if(this.End_Date__c < this.Start_Date__c){
            this.template.querySelector('c-mtp_-toast-message').showToast('error', 'End Date should not Before Start Date', 3000);
        }
        else if(this.Day__c == '' || this.Day__c == null || this.Day__c == undefined){
            this.template.querySelector('c-mtp_-toast-message').showToast('error', 'Please Select Day Type ', 3000);
        }
        else if((this.Day__c == 'First Half' || this.Day__c == 'Second Half') && (this.Start_Date__c != this.End_Date__c)){
            this.template.querySelector('c-mtp_-toast-message').showToast('error', 'For Half Day Leave Start Date and End Date Must be Same ', 3000);
        }
        else if(this.Leave_Type__c == '' || this.Leave_Type__c == null || this.Leave_Type__c == undefined){
            this.template.querySelector('c-mtp_-toast-message').showToast('error', 'Please Select Leave Type', 3000);
        }
        else if(this.Reason__c == '' || this.Reason__c == null || this.Reason__c == undefined){
            this.template.querySelector('c-mtp_-toast-message').showToast('error', 'Please Select Reason', 3000);
        }
        else{

            this.isSpinner = true;
            const SaveBtn = this.template.querySelector('[data-id = "Reason__c"]');
            this.Start_Date__c = '';
            this.End_Date__c = '';
            this.Day__c = '';
            this.Leave_Type__c = '';
            this.Reason__c = '';
            this.ShowApplyForLeave = false;
            
            SAVELeave({inputFields : JSON.stringify(this.inputFieldValues), UserId : this.userId})
            .then(result =>{
                this.template.querySelector('c-mtp_-toast-message').showToast('success', result, 3000);
                this.getLeavesListForAll(this.dataname);    
                this.isSpinner = false;
            })
            .catch(error =>{
                console.log('Error : ',error);
                this.isSpinner = false;
            })
        }
       
        }
        catch(error){
            console.log('error in SAVELeave: ',error);
        }

    }

        HandleMonthchange(event){
            try{
            this.isSpinner = true;
                setTimeout(() => {
                    this.isSpinner = false;        
                }, 500);
                this.SelectedMonth = event.target.value;
                
                this.getLeavesListForAll(this.dataname); 
        }
        catch(error){
            console.log('Error in HandleMonthchange-->',{error});
        }
        }


        SetYEarPicklistValues(){
            try{

        var YearPickList = [];
        YearPickList.push({
            label : 'All Years', value : '0000'
        });
        for ( var i=2023; i<= 2050; i++){
            YearPickList.push({
                label: i.toString(), value: i.toString()
            });
        } 
        this.years = YearPickList;
    }
    catch(error){
        console.log('Error in SetYEarPicklistValues-->',{error});
    }
            
    }

        HandleYearChange(event){
            try{
            this.isSpinner = true;
                setTimeout(() => {
                    this.isSpinner = false;        
                }, 500);
            this.SelectedYearValue = event.target.value;
            
                this.getLeavesListForAll(this.dataname); 
        }
        catch(error){
            console.log('Error in HandleYearChange-->',{error});
        }
        }

    

        getLeaveList(event){
        try{
            
                 this.dataname = event.currentTarget.dataset.name;
                this.getLeavesListForAll(this.dataname);
            
        }
        catch(error){
            console.log('Error in getLeaveList-->',{error});
        }

        }


        getLeavesListForAll(name){     
        try{
            this.isSpinner = true;
            if(name == 'PendingLeaves'){
                this.UtilityIcon  = 'utility:resource_capacity';

                allLeavesList({LeavesStatus : 'Pending for Approval', Months : this.SelectedMonth, years : this.SelectedYearValue})
                .then(result => {
                    this.LeaveDetails = result;                         // Add Leaves List in For Each Tempalate
                    this.lvt_type_color = 'lv-type';
                    this.LeaveStatus = 'Pending Leaves';
                    this.TotalLeaves = result.length;
                    this.ShowDELETEbtn = true;                // Set dynamic header

                    if(result.length == 0){                               // hide Show Illustration
                        this.ShowIllustration = true;
                    } else{
                        this.ShowIllustration = false;
                    }
                    this.isSpinner = false;
                })
                .catch(err =>{
                    console.log('Eroor is ', err);
                    this.isSpinner = false;
                })
            }
            else if(name == 'ApprovedLeaves'){
             
                this.UtilityIcon  = 'utility:smiley_and_people';
                allLeavesList({LeavesStatus : "Approved", Months : this.SelectedMonth, years : this.SelectedYearValue})
                .then(result => {
                    this.LeaveDetails = result;
                    this.lvt_type_color = 'lv-type-Approved';
                    this.LeaveStatus = 'Approved Leaves';
                    this.TotalLeaves = result.length;
                    this.ShowDELETEbtn = false; 

                    if(result.length == 0){
                        this.ShowIllustration = true;
                    } else{
                        this.ShowIllustration = false;
                    }
                    this.isSpinner = false;
                })
                .catch(err =>{
                    console.log('Eroor is ', err);
                    this.isSpinner = false;
                })

            } else if (name == 'RejectedLeaves'){
               
                this.UtilityIcon  = 'utility:sentiment_negative';

                allLeavesList({LeavesStatus : "Rejected", Months : this.SelectedMonth, years : this.SelectedYearValue})
                .then(result => {
                    this.LeaveDetails = result;
                    this.lvt_type_color = 'lv-type-Rejected';
                    this.LeaveStatus = 'Rejected Leaves';
                    this.TotalLeaves = result.length;
                    this.ShowDELETEbtn = false; 
   
                    if(result.length == 0){
                        this.ShowIllustration = true;
                    } else{
                        this.ShowIllustration = false;
                    }
                    this.isSpinner = false;
                })
                .catch(err =>{
                    console.log('Eroor is ', err);
                    this.isSpinner = false;
                })
            }
                
        }
        catch(error){
            console.log('Error in getLeavesListForAll-->',{error});
        }      

    }
        
    OpenApplyForLeave(){
        try{
            this.isSpinner = true;
            this.ShowApplyForLeave = true;
            this.isSpinner = false;
        }
        catch(error){
            console.log('Error in OpenApplyForLeave-->',{error});
        }

    }

    CloseApplyForLeave(){
        try{
            this.isSpinner = true;
            this.ShowApplyForLeave = false;
            this.Start_Date__c = '';
            this.End_Date__c = '';
            this.Day__c = '';
            this.Leave_Type__c = '';
            this.Reason__c = '';
            this.isSpinner = false;
        }
        catch(error){
            console.log('Error in CloseApplyForLeave-->',{error});
        }
    }


// =============> Function to Show Log On Submit button click <===========================
    handleSubmit(event){
        try{
            this.isSpinner = true;
            const inputFields = event.detail.fields;
            this.template.querySelector('lightning-record-edit-form').submit(inputFields);
            this.isSpinner = false;
        }
        catch(error){
            console.log('Error in handleSubmit-->',{error});
        }
    }    



    handleSuccess(){
        try{

            this.ShowApplyForLeave = false,
            this.getLeavesListForAll(this.dataname);
    
            this.template.querySelector('c-mtp_-toast-message').showToast('success', 'Leave Apply Succesfully', 3000);
        }
        catch(error){
            console.log('Error in handleSuccess-->',{error});
        }
        
    }

    handleError(error){
        try{

            this.template.querySelector('c-mtp_-toast-message').showToast('error', 'Please Enter Valid Data', 3000);
                        
        }
        catch{
            console.log('Error in handleError-->',{error});
        }
    }

    getDataValue(event){
        try{
            this.isSpinner = true;
            this.Lev_Id = event.currentTarget.dataset.levid;
            this.Lev_Name = event.currentTarget.dataset.levname;
            this.Lev_DayType = event.currentTarget.dataset.day;
            this.Lev_StartDay = event.currentTarget.dataset.startdate;
            this.Lev_EndDay = event.currentTarget.dataset.enddate;
            this.Lev_Reason = event.currentTarget.dataset.reason;
            this.Lev_Status = event.currentTarget.dataset.status;
            this.Lev_LeaveType = event.currentTarget.dataset.leavetype; 
                this.ShowLeaveDetailPopup = true;
                this.isSpinner = false;
    }
    catch(error){
        console.log('Error in getDataValue-->',{error});
    }
    }

     closeLeaveDeatilPopup(){
        this.ShowLeaveDetailPopup = false;
    }

    OpenAlertpopup(event){
        event.stopPropagation();
        this.recordid = event.currentTarget.dataset.levid;
        this. ShowDeleteAlertPopup = true;
    }
    CloseAlertpopup(){
        this. ShowDeleteAlertPopup = false;
    }

    handleDeleteLeave(event){
        try{
            this.isSpinner = true;
            let CancelReason = this.template.querySelector('[data-id="CancelReason"]').value
            // console.log(CancelReason);
            DeleteLeaves({Id : this.recordid, CancelReason : CancelReason})
            .then(result =>{
                // console.log(result);
                this. ShowDeleteAlertPopup = false;
                this.getLeavesListForAll(this.dataname);
                this.template.querySelector('c-mtp_-toast-message').showToast('success', 'Leave Delete SucessFully', 3000);
                this.isSpinner = false;
                
            })
            .catch(error =>{
                console.log('Error => ',error);
                this.isSpinner = false;
            })
            }
        catch(error){
            console.log('Error in handleDeleteLeave-->',{error});
        }
    }

    handleStartDateChange(event){ //
        this.Start_Date__c = this.template.querySelector('[data-id = "Start_Date__c"]').value;
        if(this.Start_Date__c != null && this.Start_Date__c != undefined && this.Start_Date__c != '' ){
            console.log('Date changed : ', this.Start_Date__c);
            SetLeaveTypePicklist({Cd : this.todayDate, Ld : this.Start_Date__c})
            .then(result =>{
                // console.log(JSON.parse(JSON.stringify(result)));
                this.LeaveTypePicklist = result.map((item) => Object.assign({}, item, { label: item, value: item }));
            })
            .catch(error =>{
                console.log('Error => ',error.body.message);
            })
        }
    }

}