import { LightningElement, api, track, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import ExternalCSS from '@salesforce/resourceUrl/ExternalCSS';
import USER_ID from '@salesforce/user/Id';
import createTimeSheetRec from '@salesforce/apex/TimesheetControllerV3.createTimeSheetRec';


export default class mtp_createTimeSheetModelPopUp extends LightningModal {
    userid = USER_ID;
    @api isPreview;
    @api todayDate;
    @api yesterdayDate;
    @api headerText;
    @api timeSheetObj;
    @api allProjectMap;
    @track disableField = false;
    @track disableSave = false;

    renderedCallback() {
        try {
            Promise.all([loadStyle(this, ExternalCSS)]);
        }
        catch (error) {
            console.log('renderedCallback Error ==> ',error);
        }
    }

    connectedCallback(){
        if (!this.isPreview) {
            let timeSheetObj = JSON.parse(JSON.stringify(this.timeSheetObj)); 
            let currentDate = timeSheetObj['Date__c'];
            if (currentDate == this.todayDate) {
                timeSheetObj['Start_Time__c'] = '';
                timeSheetObj['End_Time__c'] = '';
            } else {
                timeSheetObj['Date__c'] = this.todayDate;
            }
            this.timeSheetObj = timeSheetObj;
        }
    }

    handleUpdateChange(event){
        let fieldId = event.currentTarget.dataset.id;
        let value = this.template.querySelector('[data-id="'+fieldId+'"]').value;
        if (fieldId == 'Date__c') {
            let dateList = this.checkWeekend();
            if (value != this.todayDate &&  value != this.yesterdayDate && !dateList.includes(value)) {
                this.ShowToast('Error', 'Error', 'Please select valid date');
                this.template.querySelector('[data-id="'+fieldId+'"]').value = '';
                value = ''
            }
        }
        this.timeSheetObj[fieldId] = value;
        if ((fieldId == 'Start_Time__c' || fieldId == 'End_Time__c') && 
            (this.timeSheetObj['Start_Time__c'] != undefined && this.timeSheetObj['Start_Time__c'] != '') && 
            (this.timeSheetObj['End_Time__c'] != undefined && this.timeSheetObj['End_Time__c'] != '')) {
                let duration = ((this.convetToMilliseconds(this.timeSheetObj['End_Time__c']) - this.convetToMilliseconds(this.timeSheetObj['Start_Time__c']))/60000)/60;
                this.timeSheetObj['Hours__c'] = Number(duration.toFixed(2));
        }
    }

    checkWeekend(){
        let todayDate = new Date(this.todayDate);
        let todayDay = todayDate.getDay();

        if (todayDay == 1) {
            let oldDay1 = new Date(todayDate);
            oldDay1.setDate(oldDay1.getDate() -2);

            let oldDay2 = new Date(todayDate);
            oldDay2.setDate(oldDay2.getDate() -3);

            let oldDay1String = this.formatDate(oldDay1);
            let oldDay2String = this.formatDate(oldDay2);

            return [oldDay1String, oldDay2String];
        } else if (todayDay == 0) {
            let oldDay1 = new Date(todayDate);
            oldDay1.setDate(oldDay1.getDate() -2);

            let oldDay1String = this.formatDate(oldDay1);

            return [oldDay1String];
        } else {
            return [];
        }
    }
    
    handleCreate(){
        this.disableSave = true;
        let timeSheetObj = this.timeSheetObj;
        console.log('timeSheetObj ==> ',timeSheetObj);
        if (timeSheetObj.Start_Time__c == undefined || timeSheetObj.Start_Time__c == '' || timeSheetObj.End_Time__c == undefined || timeSheetObj.End_Time__c == '' || 
            timeSheetObj.Project__Name == undefined || timeSheetObj.Project__Name == '' || timeSheetObj.Task_Type__c == undefined || timeSheetObj.Task_Type__c == '' || 
            timeSheetObj.Task_Name__c == undefined || timeSheetObj.Task_Name__c == '' || timeSheetObj.Task_Description__c == undefined || timeSheetObj.Task_Description__c == '' ||
            timeSheetObj.Date__c == undefined || timeSheetObj.Date__c == '') {
                this.ShowToast('Error', 'Error', "Missing Required value to Save Timesheet");
                this.disableSave = false;
        } else {
            let newTSData = {};
            newTSData.Date__c = this.timeSheetObj['Date__c'];
            newTSData.Start_Time__c = this.convetToMilliseconds(this.timeSheetObj['Start_Time__c']);
            newTSData.End_Time__c = this.convetToMilliseconds(this.timeSheetObj['End_Time__c']);
            newTSData.Project__c = this.allProjectMap.get(this.timeSheetObj['Project__Name']);
            newTSData.Task_Type__c = this.timeSheetObj['Task_Type__c'];
            newTSData.Task_Name__c = this.timeSheetObj['Task_Name__c'];
            newTSData.Task_Description__c = this.timeSheetObj['Task_Description__c'];
            console.log('newTSData ==> ',newTSData);

            if (this.timeSheetObj['Hours__c'] > 4) {
                this.ShowToast('Error', 'Error', "Interval must be less or equal to 4 hours");
                this.disableSave = false;
            } else if (newTSData.Start_Time__c > newTSData.End_Time__c || newTSData.Start_Time__c == newTSData.End_Time__c) {
                this.ShowToast('Error', 'Error', "End Time must be greater than Start Time");
                this.disableSave = false;
            } else if (newTSData.Task_Description__c.trim().length < 50){
                this.ShowToast('Error', 'Error', "Your description is too short");
                this.disableSave = false;
            } else {
                console.log('createTimeSheetRec');
                createTimeSheetRec({newTSData: JSON.stringify(newTSData), userId: this.userid})
                .then(result => {
                    if (result == null) {
                        this.ShowToast('Error', 'Error', 'Timesheet already submited for '+newTSData.Date__c);
                    } else {
                        this.ShowToast('Success', 'Success', 'Timesheet Created Successfully');
                        this.close(newTSData.Date__c);
                    }
                    this.disableSave = false;
                })
                .catch(error => {
                    this.ShowToast('Error', 'Error', 'Something Went Wrong!!!');
                    console.log('handleCreate Error ==> ',error);
                    this.disableSave = false;
                });
            }
        }
    }

    handleCancel() {
        this.close();
    }

    formatDate(date) {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, "0");
        const day = String(date.getDate()).padStart(2, "0");
        return `${year}-${month}-${day}`;
    }

    convetToMilliseconds(timeString) {
        let [hoursStr, minutesStr] = timeString.split(':');
        let hours = parseInt(hoursStr, 10);
        let minutes = parseInt(minutesStr, 10);
        let totalMilliseconds = (hours * 60 * 60 * 1000) + (minutes * 60 * 1000);
        return totalMilliseconds;
    }

    ShowToast(variant, title, message) {
        let evt = new ShowToastEvent({
            variant: variant,
            title: title,
            message: message,
            duration: 3000,
        });
        this.dispatchEvent(evt);
    }
}