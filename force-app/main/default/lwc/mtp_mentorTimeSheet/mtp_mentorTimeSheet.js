import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
import getOrgDate from '@salesforce/apex/TimesheetControllerV2.getOrgDate';
import mtp_createTimeSheetModelPopUp from 'c/mtp_createTimeSheetModelPopUp'
import mtp_submitButtonPopUp from 'c/mtp_submitButtonPopUp';
import mtp_updateTimesheetPopUp from 'c/mtp_updateTimesheetPopUp';
import getUserTypeMts from '@salesforce/apex/TimesheetControllerV2.getUserTypeMts';
import getMentorTimesheetData from '@salesforce/apex/TimesheetControllerV2.getMentorTimesheetData';
import deleteTimesheetRecord from '@salesforce/apex/TimesheetControllerV2.deleteTimesheetRecord';
import ShowSubmitCreateBut from '@salesforce/apex/TimesheetControllerV2.ShowSubmitCreateBut';

export default class mtp_mentorTimeSheet extends NavigationMixin(LightningElement) {

    @track userid = USER_ID;
    @track isNext = true;
    @track mentor = false;
    @track trainee = false;
    @track isSpinner = false;
    @track editDeleteButton = true;
    @track CreateSubmitButton = true;
    @track timesheetDataList = false;
    @track timesheetData = [];
    @track selectedRecordsId = [];
    @track SubmitTimeSheet = [];
    @track date ;
    @track todayDate;
    @track tomorrowDate;
    @track yesterdayDate;
    @track contactType;
    @track statusValue = 'Pending';
    @track selectedTrainee;
    @track ApproveReject = false;
    @track UserName;


    @wire(getUserTypeMts, { userid :  '$userid' })
    getUserTypeMts(value) {
        console.log('value -----> ' + value);
        this.isSpinner = true;
        const { data, error } = value;
        console.log('data --->' , {data} );
        if(data) {
            this.contactType = data[1];
            if(this.contactType == 'Senior Developer'){
                this.mentor = true;
                this.UserName = data[0];
                this.handleDateChange();
            }
            else{
                var pageapiname ='Error'
                this.handleNavigation(pageapiname);
            }
        } else if(error) {
            this.isSpinner = false;
            console.log('getUserTypeMts--->',{error});
        }
    }


    connectedCallback() {
     
    }
    getTimesheetData(){
        try{
            this.selectedRecordsId = [];
            this.isSpinner = true;
    
            getMentorTimesheetData({userId:this.userid , selectedContactId : this.selectedTrainee ,seldate : this.date,statusValue:this.statusValue , project : this.selectedProject , contactType : this.contactType})
            .then(result => {
                if(result.length > 0){
                    this.timesheetDataList = true;
                    this.isApproveAll = false;
                    this.timesheetData = result;                
                }else{
                    this.timesheetData = [];
                    this.isApproveAll = true;
                    this.timesheetDataList = false;
                }
            if((this.timesheetData.length == 0 || this.timesheetData[0].Status__c == null ) && this.statusValue =='Pending' ){
                console.log('this.timesheetData.length',this.timesheetData.length);
                ShowSubmitCreateBut({seldate : this.date}) 
                .then(result => {
                    this.CreateSubmitButton = result;
                })
                .catch(err =>{
                    console.log(err);
                })
            }else{
                this.CreateSubmitButton = false;
            }
                this.isSpinner = false;
                if((this.date == this.todayDate && this.statusValue =='Rejected'  ) || (this.date == this.yesterdayDate && this.statusValue =='Rejected'  )){
                    this.editDeleteButton = true;
                }else{
                    this.editDeleteButton = false;
                }     
            })
            .catch(error => {
                this.error = error;
                this.isSpinner = false;
            });
        }
        catch(error){
            console.log('Error in getTimesheetData-->',{error});
        }
        
    }
    createTimesheet(event){
        try{
            var id = '';
                this.isSpinner = true;
                id = event.target.value;
                mtp_createTimeSheetModelPopUp.open({
                    selectedRecordId : id,
                    label : 'Timesheet Details',
                    CurrentDate : this.date,
                    type : 'Create',
                    ApproveReject : this.ApproveReject
                }).then(result => {
                    this.getTimesheetData();
                }
                ).catch(error => {
                    this.isSpinner = false;
                    this.error = error;
                    // show toast error message
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Error in creating Timesheet',
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                });
                this.isSpinner = false;
        }catch(error){
            console.log('Error in createTimesheet-->',{error});
        }
    }
    deleteTimesheetRecord(event){
        try{
            this.isSpinner = true;
        var id = event.target.value;
        deleteTimesheetRecord({timesheetdetailId : id})
        .then(result => {
            this.getTimesheetData();
            if(result == 'Success'){
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: 'Timesheet Deleted Successfully',
                    variant: 'success',
                    duration: 3000,
                });
                this.dispatchEvent(evt);
            }
        })
        .catch(error => {
            this.isSpinner = false;
            this.error = error;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Error in deleting Timesheet',
                variant: 'error',
                duration: 3000,
            });
            this.dispatchEvent(evt);    
        });
        this.isSpinner = false;
        }
        catch(error){
            console.log('Error in deleteTimesheetRecord-->',{error});
        }
    }
    handleDateChange(event){
        try{
            if(this.date != undefined && event.target.value > this.todayDate){
                
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'You can not select future date : ' + event.target.value,
                    variant: 'error',
                    duration: 3000,
                });
                this.dispatchEvent(evt);
                event.target.value = this.date;
                this.getTimesheetData();
        }else{
            this.isSpinner = true;
            if(this.date == undefined){
                getOrgDate()
                .then(result => {
                    this.todayDate = result;
                    this.date = result;
                    this.getTimesheetData();
                    this.isSpinner = false;

                    var yesterday = new Date(this.todayDate);
                    yesterday.setDate(yesterday.getDate() - 1);
                    this.yesterdayDate = yesterday.toISOString().split('T')[0];
                })
                .catch(error => {
                    this.isSpinner = false;

                    this.error = error;
                });
            }
            else{
                this.date = event.target.value;
                this.getTimesheetData();
                this.isSpinner = false;
            }
        }
        if(this.date == this.todayDate || this.date > this.todayDate){
            this.isNext = true;
        }else if(this.date < this.todayDate){
            this.isNext = false;
        }
        }
        catch(error){
            console.log('Error in handleDateChange-->',{error});
        }
        
    }
    handleStatus(event){
        try{
            this.isSpinner = true;
            this.statusValue = event.currentTarget.dataset.value;
            this.getTimesheetData();
        }
        catch(error){
            console.log('Error in handleStatus-->',{error});
        }
        
    }
    handlesubmit(){
        try{
            mtp_submitButtonPopUp.open({
                
                contactType : 'Senior Developer',
                selectedId :  this.userid,
                label : 'Submit',
                content :'you would not be able to edit , create and delete the timesheet after submission.',
                selectedDate : this.date,

            }).then(result => {
                this.isSpinner = true;
                    setTimeout(() => {
                    this.getTimesheetData();
                    this.isSpinner = false;
                }, 1000);
            }
            ).catch(error => {
                this.isSpinner = false;
    
                this.error = error;
            });
        }
        catch(error){
            console.log('Error in handlesubmit-->',{error});
        }
    }
    handlePreviewRecord(event){
        try{
            const selectedId = event.target.value;
            // const selectedId = event.currentTarget.dataset.value;
            mtp_createTimeSheetModelPopUp.open({
                selectedRecordId :  selectedId,
                label : 'Timesheet Preview',
                type : 'Preview',
                ApproveReject : this.ApproveReject
            });
        }catch(error){
            this.isSpinner = false;

            console.log('Error in handlePreviewRecord --> ',{error});
        }
    }   
    handlepreviousDate() {
    try {
            this.isApprove = true;
            let date = new Date(this.date);
            date.setDate(date.getDate() - 1);
            if(date.getMonth() + 1 < 10 && date.getDate() < 10){    
                this.date = date.getFullYear() + '-0' + (date.getMonth() + 1) + '-0' + date.getDate();
            }else if(date.getMonth() + 1 < 10){
                this.date = date.getFullYear() + '-0' + (date.getMonth() + 1) + '-' + date.getDate();
            }else if(date.getDate() < 10){
                this.date = date.getFullYear() + '-' + (date.getMonth() + 1) + '-0' + date.getDate();
            }else{
                this.date = date.getFullYear() + '-' + (date.getMonth() + 1) + '-' + date.getDate();
            }
            this.getTimesheetData();

            if(this.date == this.todayDate || this.date > this.todayDate){
                this.isNext = true;
            }else if(this.date < this.todayDate){
                this.isNext = false;
            }   
        } catch (error) {
            this.isSpinner = false;

            console.log('error in handlepreviousDate --> ',{error});   
        }   
    }
    handlenextDate(){
        try{    
            this.isApprove = true;
            let date = new Date(this.date);
            date.setDate(date.getDate() + 1);
            if(date.getMonth() + 1 < 10 && date.getDate() < 10){    
                this.date = date.getFullYear() + '-0' + (date.getMonth() + 1) + '-0' + date.getDate();
            }else if(date.getMonth() + 1 < 10){
                this.date = date.getFullYear() + '-0' + (date.getMonth() + 1) + '-' + date.getDate();
            }else if(date.getDate() < 10){
                this.date = date.getFullYear() + '-' + (date.getMonth() + 1) + '-0' + date.getDate();
            }else{
                this.date = date.getFullYear() + '-' + (date.getMonth() + 1) + '-' + date.getDate();
            }
            this.getTimesheetData();

            if(this.date == this.todayDate || this.date > this.todayDate){
                this.isNext = true;
            }else if(this.date < this.todayDate){
                this.isNext = false;
            }
        }catch(error){
            this.isSpinner = false;

            console.log('error in handlenextDate -->',{error});
        }
    }
    updateTimesheet(event){
        try{
            // get timesheet record id through value attribute
        const selectedId = event.target.value;
        // call update function 
        mtp_updateTimesheetPopUp.open({
            selectedRecordId :  selectedId,
            label : 'Update Timesheet',
        }).then(result => {
            this.getTimesheetData();
        }
        ).catch(error => {
            this.isSpinner = false;

            this.error = error;
            console.log({error});
            // show toast error message
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Error in creating Timesheet',
                variant: 'error',
            });
            this.dispatchEvent(evt);
        }
        );
        }
        catch(error){
            console.log('Error in updateTimesheet-->',{error});
        }
        
    }

    handleNavigation(pageApiName) {
        try {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: pageApiName,
                },
            });
        } catch (error) {
            this.isSpinner = false;
            console.log('Error in handleNavigation method ==>', {error});
        }
    }

}