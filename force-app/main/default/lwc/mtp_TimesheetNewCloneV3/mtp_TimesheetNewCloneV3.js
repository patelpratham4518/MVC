import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
import TS_Detail_OBJECT from '@salesforce/schema/Timesheet_Detail__c';
import TYPE_FIELD from '@salesforce/schema/Timesheet_Detail__c.Task_Type__c'
import {getObjectInfo, getPicklistValues} from 'lightning/uiObjectInfoApi';
import mtp_createTimeSheetModelPopUpV3 from 'c/mtp_createTimeSheetModelPopUpV3'
import getRelatedData from '@salesforce/apex/TimesheetControllerV3.getRelatedData';
import getTimesheetRec from '@salesforce/apex/TimesheetControllerV3.getTimesheetData';
import submitTimesheet from '@salesforce/apex/TimesheetControllerV3.submitTimesheet';
import unlockTimesheet from '@salesforce/apex/TimesheetControllerV3.unlockTimesheet';
import deleteTimesheetRecord from '@salesforce/apex/TimesheetControllerV3.deleteTimesheetRecord';
import createTimeSheetRec from '@salesforce/apex/TimesheetControllerV3.createTimeSheetRec';
import updateTimeSheet from '@salesforce/apex/TimesheetControllerV3.updateTimeSheet';
import updateProjects from '@salesforce/apex/TimesheetControllerV3.updateProjects';

export default class mtp_TimesheetNewCloneV3 extends NavigationMixin(LightningElement) {

    userid = USER_ID;
    @track contactData;
    @track tsMetadata;
    @track taskTypes = [];
    @track isNext = true;
    @track isSpinner = true;
    @track createSubmitButton = true;
    @track timesheetDataList = false;
    @track allProjectMap;
    @track allProjectList = [];
    @track projectList = [];
    @track timesheetData = [];
    @track todayDate;
    @track yesterdayDate;
    @track date;
    @track submitPopUp = false;
    @track showButtons = false;
    @track checkWeekends = false;
    @track timeSheetObj = {};
    @track viewMode = true;
    @track disableSave = false;
    @track projectModal = false;
    @track showProjectBtn = false;
    @track previousSelectedProjects = [];
    @track newSelectedProjects = [];

    get acceptedFormats() {
        return [".csv"];
    }

    get timeDivClass() {
        return this.viewMode ? 'read-only time-field' : 'time-field';
    }

    get tableClass(){
        return this.viewMode ? 'rwd-table ' : 'input-table';
    }

    @wire(getObjectInfo, { objectApiName: TS_Detail_OBJECT })
    tsMetadata;

    @wire(getPicklistValues, { recordTypeId: '$tsMetadata.data.defaultRecordTypeId', fieldApiName: TYPE_FIELD})
    wiredTaskTypes({ data, error }) {
        if (data) {
            data.values.forEach(element => {
                this.taskTypes.push({label: element.value});
            });
        } else if (error) {
            console.log('getPicklistValues Error ==> ',error);
        }
    }

    connectedCallback() {

        getRelatedData()
            .then(result => {
                console.log('result ==> ',result);
                this.contactData = result.contactData;

                if (result.contactData.ContactType__c != 'Trainee') {
                    this.showProjectBtn = true;
                }

                this.allProjectList = result.allProjects.map((item) => Object.assign({}, item, { label: item.Name, value: item.Name }));
                this.allProjectMap = new Map(result.allProjects.map(element => [element.Name, element.Id]));
                
                this.projectList = result.selectedProjects.map((item) => Object.assign({}, item, { label: item.Name, value: item.Name }));
                result.selectedProjects.forEach(element => {
                    this.previousSelectedProjects.push(element.Name);
                });

                
                let currentDate = new Date(result.todayDate);
                let yesterday = new Date(result.todayDate);

                yesterday.setDate(currentDate.getDate() - 1);

                let currentDateString = this.formatDate(currentDate);
                let yesterdayDateString = this.formatDate(yesterday);
        
                this.todayDate = currentDateString;
                this.yesterdayDate = yesterdayDateString;
        
                setTimeout(() => {
                    this.handleDateChange();
                }, 1500);
                
            }).catch(error => {
                console.log('getRelatedData Error ==> ',error);
                this.ShowToast('Error', 'Error', 'Something Went Wrong!!!');
            });
    }

    handleDateChange(event) {
        this.isSpinner = true;
        if (this.date != undefined && event.target.value > this.todayDate) {
            this.ShowToast('Error', 'Error', 'You can not select future date : ' + event.target.value)
            event.target.value = this.todayDate;
            this.getTimesheetData();
        } else {
            if (this.date == undefined) {
                this.date = this.todayDate;
                this.getTimesheetData();
            }
            else {
                this.date = event.target.value;
                this.getTimesheetData();
            }
        }

        if (this.date == this.todayDate || this.date > this.todayDate) {
            this.isNext = true;
        } else if (this.date < this.todayDate) {
            this.isNext = false;
        }
    }

    getTimesheetData() {
        this.isSpinner = true;
        this.checkWeekend();
        getTimesheetRec({ contactId: this.contactData.Id, selectedDate: this.date })
            .then(result => {
                this.manageTimesheetData(result);
                this.isSpinner = false;

                if (this.date != this.todayDate && this.date != this.yesterdayDate && !this.checkWeekends) {
                    this.showButtons = false;
                } else {
                    this.showButtons = true;
                }
            })
            .catch(error => {
                console.log('getTimesheetData Error ==> ',error);
                this.isSpinner = false;
            });
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

            if (oldDay1String == this.date || oldDay2String == this.date) {
                this.checkWeekends = true;
            } else{
                this.checkWeekends = false;
            }
        } else if (todayDay == 0) {
            let oldDay1 = new Date(todayDate);
            oldDay1.setDate(oldDay1.getDate() -2);

            let oldDay1String = this.formatDate(oldDay1);

            if (oldDay1String == this.date) {
                this.checkWeekends = true;
            } else{
                this.checkWeekends = false;
            }
        } else {
            this.checkWeekends = false;
        }
    }

    manageTimesheetData(result){
        console.log('manageTimesheetData ==> ',result);
        this.viewMode = true;
        result.forEach(element => {
            if (element.Project__c != null && element.Project__c != undefined && element.Project__c != '') {
                element.Project__Name = element.Project__r.Name;
            }

            let projectList = JSON.parse(JSON.stringify(this.projectList));
            let taskTypes = JSON.parse(JSON.stringify(this.taskTypes));

            element.Start_Time__c = this.ConvertToInt(element.Start_Time__c);
            element.End_Time__c = this.ConvertToInt(element.End_Time__c);

            element.projectList = projectList;
            element.projectList.forEach(ele => {
                ele.selected = ele.label == element.Project__Name ? true : false;
            });
            if (!this.previousSelectedProjects.includes(element.Project__Name)) {
                element.projectList.push({label: element.Project__Name, value: element.Project__Name, selected: true});
            }
            
            element.taskTypes = taskTypes;
            element.taskTypes.forEach(ele => {
                ele.selected = ele.label == element.Task_Type__c ? true : false;
            });
            
            element.Start_Time__Id = element.Id+'?Start_Time__c';
            element.End_Time__Id = element.Id+'?End_Time__c';
            element.Project__Id = element.Id+'?Project__Name';
            element.Task_Type__Id = element.Id+'?Task_Type__c';
            element.Task_Name__Id = element.Id+'?Task_Name__c';
            element.Task_Description__Id = element.Id+'?Task_Description__c'; 
        });
        
        this.timesheetData = result;

        if (result.length > 0) {
            this.timesheetDataList = true;
            if (result[0].Timesheet__r.isSubmitted__c) {
                this.createSubmitButton = false;
            } else {
                this.createSubmitButton = true;
            }
        } else {
            this.timesheetDataList = false;
            this.createSubmitButton = true;
        }
        this.isSpinner = false;
    }

    handleInputChange(event){
        let fieldId = event.currentTarget.dataset.id;
        this.timeSheetObj[fieldId] = this.template.querySelector('[data-id="'+fieldId+'"]').value;
        if ((fieldId == 'Start_Time__c' || fieldId == 'End_Time__c') && 
            (this.timeSheetObj['Start_Time__c'] != undefined && this.timeSheetObj['Start_Time__c'] != '') && 
            (this.timeSheetObj['End_Time__c'] != undefined && this.timeSheetObj['End_Time__c'] != '')) {
                let duration = ((this.convetToMilliseconds(this.timeSheetObj['End_Time__c']) - this.convetToMilliseconds(this.timeSheetObj['Start_Time__c']))/60000)/60;
                this.timeSheetObj['Hours__c'] = Number(duration.toFixed(2));
        }
    }

    createTimesheet(event){
        this.disableSave = true;
        let timeSheetObj = this.timeSheetObj;
        if (timeSheetObj.Start_Time__c == undefined || timeSheetObj.Start_Time__c == '' || timeSheetObj.End_Time__c == undefined || timeSheetObj.End_Time__c == '' || 
            timeSheetObj.Project__Name == undefined || timeSheetObj.Project__Name == '' || timeSheetObj.Task_Type__c == undefined || timeSheetObj.Task_Type__c == '' || 
            timeSheetObj.Task_Name__c == undefined || timeSheetObj.Task_Name__c == '' || timeSheetObj.Task_Description__c == undefined || timeSheetObj.Task_Description__c == '') {
                this.ShowToast('Error', 'Error', "Missing Required value to Save Timesheet");
                this.disableSave = false;
        } else {
            let newTSData = {};
            newTSData.Date__c = this.date;
            newTSData.Start_Time__c = this.convetToMilliseconds(this.timeSheetObj['Start_Time__c']);
            console.log(newTSData.Start_Time__c);
            newTSData.End_Time__c = this.convetToMilliseconds(this.timeSheetObj['End_Time__c']);
            newTSData.Project__c = this.allProjectMap.get(this.timeSheetObj['Project__Name']);
            newTSData.Task_Type__c = this.timeSheetObj['Task_Type__c'];
            newTSData.Task_Name__c = this.timeSheetObj['Task_Name__c'];
            newTSData.Task_Description__c = this.timeSheetObj['Task_Description__c'];

            if (this.timeSheetObj['Hours__c'] > 4) {
                this.ShowToast('Error', 'Error', "Interval must be less or equal to 4 hours");
                this.disableSave = false;
            } else if (newTSData.Start_Time__c > newTSData.End_Time__c || newTSData.Start_Time__c == newTSData.End_Time__c) {
                this.ShowToast('Error', 'Error', "End Time must be greater than Start Time");
                this.disableSave = false;
            } else if (timeSheetObj.Task_Name__c.trim().length == 0) {
                this.ShowToast('Error', 'Error', "Your task name is too missing");
                this.disableSave = false;
            } else if (newTSData.Task_Description__c.trim().length < 50){
                this.ShowToast('Error', 'Error', "Your description is too short");
                this.disableSave = false;
            } else {
                createTimeSheetRec({newTSData: JSON.stringify(newTSData), contactId: this.contactData.Id})
                .then(result => {
                    this.ShowToast('Success', 'Success' , 'Timesheet Created Successfully');
                    this.clearTimesheetData();
                    this.manageTimesheetData(result);
                    this.isSpinner = false;
                    this.disableSave = false;
                })
                .catch(error => {
                    this.ShowToast('Error', 'Error', 'Something Went Wrong!!!');
                    console.log('createTimesheet Error ==> ',error);
                    this.isSpinner = false;
                    this.disableSave = false;
                });
            }
        }
    }

    clearTimesheetData(){
        this.timeSheetObj = {};
        if (this.template.querySelector('[data-id="Project__Name"]') != null && this.template.querySelector('[data-id="Task_Type__c"]') != null) {
            this.template.querySelector('[data-id="Project__Name"]').value = 'PreSelected';
            this.template.querySelector('[data-id="Task_Type__c"]').value = 'PreSelected';
        }
    }

    ConvertToInt(timeinput){
        if(timeinput==='12:00')
        {
            return '12:00';
        }
        let seconds = Math.floor(timeinput / 1000);
        let minutes = Math.floor(seconds / 60);
        let hours = Math.floor(minutes / 60);

        minutes = minutes % 60;
        hours = hours % 24;

        return `${this.padTo2Digits(hours)}:${this.padTo2Digits(minutes)}`;     
    }

    padTo2Digits(num) {
        return num.toString().padStart(2, '0');
    }

    deleteTimesheetRecord(event) {
        this.isSpinner = true;
        var id = event.target.value;
        deleteTimesheetRecord({ timesheetdetailId: id, contactId: this.contactData.Id, selectedDate : this.date })
            .then(result => {
                this.manageTimesheetData(result);
                this.ShowToast('Success', 'Success', 'Timesheet Deleted Successfully');
            })
            .catch(error => {
                this.isSpinner = false;
                console.log('deleteTimesheetRecord Error ==> ',error);
                this.ShowToast('Error', 'Error', 'Error in deleting Timesheet');
            });
    }

    handlePreviewRecord(event) {
        const selectedId = event.target.value;
        let timeSheet = {};
        let timesheetData = this.timesheetData;
        timesheetData.forEach(element => {
            if (element.Id == selectedId) {
                timeSheet = element;
            }
        });

        mtp_createTimeSheetModelPopUpV3.open({
            label: 'Timesheet Preview',
            contactData: this.contactData,
            isPreview: true,
            todayDate : this.todayDate,
            yesterdayDate : this.yesterdayDate,
            headerText: 'Timesheet Preview',
            timeSheetObj: timeSheet,
            allProjectMap: this.allProjectMap
        });
    }

    createDuplicateRecord(event){
        const selectedId = event.target.value;
        let timeSheet = {};
        let timesheetData = this.timesheetData;
        timesheetData.forEach(element => {
            if (element.Id == selectedId) {
                timeSheet = element;
            }
        });

        mtp_createTimeSheetModelPopUpV3.open({
            label: 'Duplicate Timesheet',
            contactData: this.contactData,
            isPreview: false,
            todayDate : this.todayDate,
            yesterdayDate: this.yesterdayDate,
            headerText: 'Duplicate Timesheet',
            timeSheetObj: timeSheet,
            allProjectMap: this.allProjectMap
        }).then(result => {
            if (result != undefined) {
                this.date = result;
                this.clearTimesheetData();
                this.checkBtn();
            }
        }
        ).catch(error => {
            this.isSpinner = false;
            console.log('createDuplicateRecord Error ==> ',error);
            this.displayToast('Error', 'Error', 'Error in Duplicate Timesheet');
        });
    }

    handlePreviousDate() {
        let date = new Date(this.date);
        date.setDate(date.getDate() - 1);
        this.date = this.formatDate(date);
        this.checkBtn();
    }

    handleNextDate() {
        let date = new Date(this.date);
        date.setDate(date.getDate() + 1);
        this.date = this.formatDate(date);
        this.checkBtn();
    }

    checkBtn(){
        this.getTimesheetData();
        if (this.date == this.todayDate || this.date > this.todayDate) {
            this.isNext = true;
        } else if (this.date < this.todayDate) {
            this.isNext = false;
        }
    }

    editTimeSheet(){
        this.viewMode = false;
    }

    handleUpdateChange(event){
        let dataId = event.currentTarget.dataset.id;
        let recId = dataId.split('?')[0];
        let fieldId = dataId.split('?')[1];

        let timesheetData = this.timesheetData;
        timesheetData.forEach(element => {
            if (element.Id == recId) {
                element[fieldId] = this.template.querySelector('[data-id="'+dataId+'"]').value;
                if ((fieldId == 'Start_Time__c' || fieldId == 'End_Time__c') && (element[fieldId] != undefined && element[fieldId] != '')) {
                    let duration = ((this.convetToMilliseconds(element['End_Time__c']) - this.convetToMilliseconds(element['Start_Time__c']))/60000)/60;
                    element['Hours__c'] = Number(duration.toFixed(2));
                }
                if (fieldId == 'Project__Name') {
                    element['Project__c'] = this.allProjectMap.get(element[fieldId]);
                    element.projectList.forEach(ele => {
                        ele.selected = ele.label == element[fieldId] ? true : false;
                    });
                }
                if (fieldId == 'Task_Type__c') {
                    element.taskTypes.forEach(ele => {
                        ele.selected = ele.label == element[fieldId] ? true : false;
                    });
                }
            }
        });
    }

    saveAllTimeSheet(){
        let timesheetData = this.timesheetData
        let missingError = false
        let durationError = false
        let timeError = false
        let descError = false

        timesheetData.forEach(element => {
            if (element.Start_Time__c == undefined || element.Start_Time__c == '' || element.End_Time__c == undefined || element.End_Time__c == '' || 
                element.Project__c == undefined || element.Project__c == '' || element.Task_Type__c == undefined || element.Task_Type__c == '' || 
                element.Task_Name__c == undefined || element.Task_Name__c == '' || element.Task_Description__c == undefined || element.Task_Description__c == '') {
                    missingError = true;
            } else if (element.Hours__c > 6) {
                durationError = true
            } else if (element.Start_Time__c > element.End_Time__c || element.Start_Time__c == element.End_Time__c) {
                timeError = true;
            } else if (element.Task_Description__c.trim().length < 50) {
                descError = true;
            }
        });
        
        if (missingError) {
            this.ShowToast('Error', 'Error', "Missing Required value to Save Timesheet");
        } else if(durationError) {
            this.ShowToast('Error', 'Error', "Interval must be less or equal to 6 hours");
        } else if(timeError) {
            this.ShowToast('Error', 'Error', "End Time must be greater than Start Time");
        } else if(descError) {
            this.ShowToast('Error', 'Error', "Your description is too short");
        } else{
            this.isSpinner = true;
            let newTSDataList = [];
            timesheetData.forEach(element => {
                let newTSData = {};
                newTSData.Id = element['Id'];
                newTSData.Date__c = element['Date__c'];
                newTSData.Timesheet__c = element['Timesheet__c'];
                newTSData.Start_Time__c = this.convetToMilliseconds(element['Start_Time__c']);
                console.log(newTSData.Start_Time__c);
                newTSData.End_Time__c = this.convetToMilliseconds(element['End_Time__c']);
                newTSData.Project__c = element['Project__c'];
                newTSData.Task_Type__c = element['Task_Type__c'];
                newTSData.Task_Name__c = element['Task_Name__c'];
                newTSData.Task_Description__c = element['Task_Description__c'];
                newTSDataList.push(newTSData);
            });

            updateTimeSheet({tsRecords: JSON.stringify(newTSDataList), contactId: this.contactData.Id, selectedDate : this.date})
            .then(result => {
                this.manageTimesheetData(result);
                this.isSpinner = false;
                this.ShowToast('Success', 'Success', 'Timesheet Updated Successfully');
            })
            .catch(error => {
                this.ShowToast('Error', 'Error', 'Something Went Wrong!!!');
                console.log('saveAllTimeSheet Error ==> ',error);
            });
        }
    }

    cancelEditTimeSheet(){
        this.getTimesheetData();
    }

    openSubmitModal() {
        this.submitPopUp = true;
    }

    closeSubmitModal(){
        this.submitPopUp = false;
    }

    handleSubmit(){
        this.isSpinner = true;
        submitTimesheet({contactId: this.contactData.Id, selectedDate : this.date})
            .then(result => {
                this.manageTimesheetData(result);
                this.ShowToast('Success', 'Success', 'Timesheet submited successfully');
                this.submitPopUp = false;
            })
            .catch(error => {
                this.isSpinner = false;
                console.log('handleSubmit Error ==> ',error);
                this.ShowToast('Error', 'Error', 'Something Went Wrong!!!');
                this.submitPopUp = false;
            });
    }

    handleUnlock(){
        this.isSpinner = true;
        unlockTimesheet({contactId: this.contactData.Id, selectedDate : this.date})
            .then(result => {
                this.manageTimesheetData(result);
                this.ShowToast('Success', 'Success', 'Timesheet unlocked successfully');
                this.submitPopUp = false;
            })
            .catch(error => {
                this.isSpinner = false;
                this.submitPopUp = false;
                console.log('handleUnlock Error ==> ',error);
                this.ShowToast('Error', 'Error', 'Something Went Wrong!!!');
            });
    }

    openProjectModal(){
        this.projectModal = true;
    }

    closeProjectModal(){
        this.projectModal = false;
    }

    handleSelectedProject(event){
        this.newSelectedProjects = event.detail.value;
    }

    handleProjectUpdate(event){
        updateProjects({projects: JSON.stringify(this.newSelectedProjects), con: this.contactData, selectedDate: this.date})
        .then(result => {
            let projectList = [];
            this.newSelectedProjects.forEach(element => {
                projectList.push({label: element, value: element});
            });
            this.projectList = projectList;
            this.previousSelectedProjects = this.newSelectedProjects;
            this.projectModal = false;
            this.manageTimesheetData(result);
            this.ShowToast('Success', 'Success', 'Timesheet Updated Successfully');
        })
        .catch(error => {
            this.ShowToast('Error', 'Error', 'Something Went Wrong!!!');
            console.log('handleProjectUpdate Error ==> ',error);
        });
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