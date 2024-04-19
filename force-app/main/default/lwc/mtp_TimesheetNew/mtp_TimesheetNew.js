import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

import USER_ID from '@salesforce/user/Id';
import CONTACT_TYPE from "@salesforce/schema/User.Contact.ContactType__c";
import LastName from '@salesforce/schema/Contact.LastName';
import LOCALE from '@salesforce/i18n/locale';

import mtp_Timesheet_bg_image from '@salesforce/resourceUrl/mtp_Timesheet_bg_image';
import mtp_Approve_icon from '@salesforce/resourceUrl/mtp_Approve_icon';
import mtp_Reject_icon from '@salesforce/resourceUrl/mtp_Reject_icon';
import mtp_Airplane_StartTime_icon from '@salesforce/resourceUrl/mtp_Airplane_StartTime_icon';
import mtp_Airplane_EndTime_icon from '@salesforce/resourceUrl/mtp_Airplane_EndTime_icon';
import mtp_Calendar_icon from '@salesforce/resourceUrl/mtp_Calendar_icon';

import getTimesheetData from '@salesforce/apex/TimesheetController.getTimesheetData';
import createTimesheetRecord from '@salesforce/apex/TimesheetController.createTimesheetRecord';
import updateStaus from '@salesforce/apex/TimesheetController.updateStaus';
import submittimesheet from '@salesforce/apex/TimesheetController.submittimesheet';
import deleteTimesheetRecord from '@salesforce/apex/TimesheetController.deleteTimesheetRecord';
import updateTimesheetDetailRecord from '@salesforce/apex/TimesheetController.updateTimesheetDetailRecord';
import getOrgDate from '@salesforce/apex/TimesheetController.getOrgDate';

export default class Mtp_TimesheetNew extends LightningElement {
    bgImage = mtp_Timesheet_bg_image;                       // background-image of timesheet component
    approveIcon = mtp_Approve_icon;                         // approve icon for timesheet
    rejectIcon = mtp_Reject_icon;                           // reject icon for timesheet 
    startTimeIcon = mtp_Airplane_StartTime_icon;            // start time (airplane) icon for timesheet
    endTimeIcon = mtp_Airplane_EndTime_icon;                // end time (airplane) icon for timesheet
    calendarIcon = mtp_Calendar_icon;                       // calendar icon for timesheet
    todaysDate;
    datevalue;
    disablefield = false;
    previewbtn = true;
    lastcolumn = true;
    comment_disable = true;
    TimesheetName ;
    @api recordId;
    @track recid = '';
    @track contacttype;
    @track sbmtbtn = false;
    @track nxtbtndis = false;
    @track isSpinner = false;
    @track timesheetDataList;
    @track taskOptionList = [];
    @track isCreateTimesheetModalOpen = false;
    @track testSD = '';
    @track tsTask = '';
    @track tsTaskDescription = '';
    @track tsDate = '';
    @track tsStartTime = '';
    @track tsEndTime = '';
    @track tsComments = '';
    @track rejectreason = '';
    @track timesheetwrap;
    @track submit = false;
    @track editcontacttype;
    @track createlabel;
    @track timesheetdetailId;
    @track disabledatefield = false;
    @track pendingforapproval = true;
    @track rejectedts = false;
    @track apexdate = '';
    @track traineeName = '';
    @track StartTimeList = [];

    get backImgHome() {
        return `background-image:url(${mtp_Timesheet_bg_image})`;
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            let urlStateParameters = currentPageReference.state;
            this.recid = urlStateParameters.recordId;
        }
    }

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [CONTACT_TYPE]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            console.log({ error });
        } else if (data) {
            let typevalue = data.fields.Contact.value.fields.ContactType__c.value;
            if (typevalue == 'Trainee') {
                this.contacttype = true;
            } else {
                this.contacttype = false;
            }
        }
    }

    get revenue() {
        return getFieldValue(this.TimesheetName, LastName);
    }

    endSpinner() {
        setTimeout(() => {
            this.isSpinner = false;
        }, 1000);
    }

    connectedCallback() {
        this.getTodaysDate();
    }

    getTodaysDate() {
        getOrgDate()
        .then(result => {
            this.isSpinner = true;
            this.apexdate = result;
            this.loaddate();
            this.isSpinner = false;
        })
        .catch(error => {
            this.template.querySelector('c-mtp_-toast-message').showToast('error', error, 3000);
        });
    }

    loaddate() {
        this.isSpinner = true;
        var date = this.apexdate;
        this.todaysDate = date;
        this.datevalue = date.substring(8, 10) + '-' + date.substring(5, 7) + '-' + date.substring(0, 4);
        this.loadwrapper();
        this.getTimesheetList();
        this.isSpinner = false;
    }

    dateupadte(days) {
        try {
            Date.prototype.addDays = function (days) {
                var date = new Date(this.valueOf());
                date.setDate(date.getDate() + days);
                return date;
            }
            var date = new Date(this.apexdate);
            var td = date.addDays(days);
            let date1 = new Date(td);
            return date1.toISOString().substring(0, 10);
        } catch (error) {
            console.log('Error in Date Update Method>>',{error});
        }
    }

    // For Navigate to Selected Date
    navigateDate(event) {
        let date = event.target.value;
        if(this.apexdate >= date) {
            this.todaysDate = date;
            this.datevalue = date.substring(8, 10) + '-' + date.substring(5, 7) + '-' + date.substring(0, 4);
            this.getTimesheetList();
        } else {
            this.template.querySelector('c-mtp_-toast-message').showToast('error', 'Please Select Valid date', 3000);
        }
    }

    // Navigate to Today's Date
    navigateToToday() {
        this.todaysDate = this.apexdate;
        this.datevalue = this.apexdate.substring(8, 10) + '-' + this.apexdate.substring(5, 7) + '-' + this.apexdate.substring(0, 4);
        this.getTimesheetList();
    }

    getTimesheetList() {
        try {
            // this.timesheetDataList = '';
            this.isSpinner = true;
            var con = '';
            if (this.recid != undefined) {
                con = this.recid;
            } else {
                con = '';
            }

            var td = new Date(this.todaysDate);
            var sd = new Date(this.dateupadte(0));
            console.log('td==>',td.toString().substring(0,3));
            console.log('sd==>',sd);
            var test_date = td - sd;
            console.log('%c'+test_date/86400000, 'background:gray;');
            if(sd.toString().substring(0,3) == 'Mon' ){
                if([0, -1, -2, -3].includes(test_date/86400000) )
                    this.previewbtn = true;
                else
                    this.previewbtn = false;
            }
            else{
                if(test_date/86400000 == 0 || test_date/86400000 == -1 )
                    this.previewbtn = true;
                else
                    this.previewbtn = false;
            }

            console.log('preview btn >>',this.previewbtn);

            let seldt = this.todaysDate;
            let crdt = this.dateupadte(0);

            if (seldt >= crdt) {
                this.sbmtbtn = true;
                this.nxtbtndis = true;
            } else {
                this.sbmtbtn = false;
                this.nxtbtndis = false;
            }
            getTimesheetData({ contactid: con, seldate: this.todaysDate })
                .then(result => {
                    var dataList = [];
                    if (result.length > 0) {
                        this.traineeName = result[0].Timesheet__r.Contact__r.Name + '\'s';
                    }
                    var stl = [];
                    for (var key in result) {
                        // console.log('key==>>',result[key]);
                        // console.log(result[key]['Start_Time__c']);
                        stl.push(result[key]['Start_Time__c']);
                        dataList.push({ value: result[key], key: key });
                    }
                    this.StartTimeList = stl;
                    if (dataList.length > 0) {
                        for (var key in dataList) {
                            if (!dataList[key].value.Timesheet__r.Daily_Status__c) {
                                this.pendingforapproval = true;
                                break;
                            } else {
                                this.pendingforapproval = false;
                            }
                        }
                        this.timesheetDataList = [];
                        this.timesheetDataList = dataList;
                    }else{
                        this.timesheetDataList = '';
                    }
                    console.log('this.StartTimeList==>>>',this.StartTimeList);
                    this.isSpinner = false;
                })
                .catch(error => {
                    console.log({ error });
                    this.isSpinner = false;
                    this.template.querySelector('c-mtp_-toast-message').showToast('error', error, 3000);
                });
        } catch (error) {
            this.isSpinner = false;
        }
    }

    openTimesheetModal() {
        this.comment_disable = false;
        this.isCreateTimesheetModalOpen = true;
        this.disabledatefield = false;
        this.createlabel = 'Create';
        this.tsTask = '';
        this.tsTaskDescription = '';
        this.tsDate = this.dateupadte(0);;
        this.tsStartTime = '';
        this.tsEndTime = '';
        this.tsComments = '';
        this.disablefield = false;
    }

    editTimesheetModal(event) {
        try {

            this.createlabel = 'Update';
            let btnvalue = event.target.dataset.name;
            var a = event.target.id;
            var timesheetid = a.split('-')[0];
            this.timesheetdetailId = timesheetid;
            this.isCreateTimesheetModalOpen = true;
            var update ;
            var firstupdate;
            this.timesheetDataList.forEach(element => {
                if (element['value']['Id']) {
                    if (element['value']['Id'] == timesheetid) {
                        this.tsTask = element['value']['Task_Name__c'];
                        this.tsTaskDescription = element['value']['Task_Description__c'];
                        this.tsDate = element['value']['Date__c'];
                        this.tsStartTime = new Intl.DateTimeFormat(LOCALE, { hour: "numeric", minute: "numeric", hour12: false }).format(element['value']['Start_Time__c']);
                        var start = [];
                        start = this.tsStartTime.split(':');
                        var newstart;
                        if (start[0] == '24') {
                            newstart = '00';
                            this.tsStartTime = newstart + ':' + start[1];
                        }
                        this.tsEndTime = Intl.DateTimeFormat(LOCALE, { hour: "numeric", minute: "numeric", hour12: false }).format(element['value']['End_Time__c']);
                        var end = [];
                        end = this.tsEndTime.split(':');
                        var newend;
                        if (end[0] == '24') {
                            newend = '00';
                            this.tsEndTime = newend + ':' + end[1];
                        }
                        this.tsComments = element['value']['Comments__c'];
                        console.log(element['value']['Status__c']);
                        if(element['value']['Status__c'] == "Approved"){
                            update = false;
                            firstupdate = false;
                        }else if(element['value']['Status__c'] == undefined){
                            firstupdate = true;
                            update = true;
                        }
                        else{
                            update = true;
                            firstupdate = false;
                        }
                    }
                }
            });

            console.log('btnvalue==>>',btnvalue );
            if (btnvalue == "Edit") {
                this.disablefield = false;
                this.disabledatefield = true;

                if(update){
                    this.disablefield = true;
                    this.disabledatefield = true;
                    this.comment_disable = false;
                    if(firstupdate){
                        this.disablefield = false;
                    }
                }
                else{
                    this.disablefield = true;
                    this.disabledatefield = true;
                    this.comment_disable = true;
                }
                
            } else {
                // only 24 hours selected
                if(this.previewbtn){
                    if(update){
                        this.disablefield = true;
                        this.disabledatefield = true;
                        this.comment_disable = false;
                    }
                    else{
                        this.disablefield = true;
                        this.disabledatefield = true;
                        this.comment_disable = true;
                    }
                }
                // before one days
                else{
                    this.disablefield = true;
                    this.disabledatefield = true;
                }
            }
        } catch (error) {
            this.template.querySelector('c-mtp_-toast-message').showToast('error', error, 3000);
        }
    }

    closeTimesheetModal() {
        this.isCreateTimesheetModalOpen = false;
    }

    NumToTime(num) {
        var hours = Math.floor(num / 60);
        var minutes = num % 60;
        if (minutes + ''.length < 2) {
            minutes = '0' + minutes;
        }
        return hours + ":" + minutes;
    }

    statusupdate(event) {
        try {
            this.isSpinner = true;
            var action = event.target.dataset.name;
            var tdid = event.target.dataset.id;
            let rejereason;

            if (action == 'Rejected' && this.rejectreason.trim().length == 0 ) {
                this.template.querySelectorAll('lightning-textarea').forEach(element => {
                    element.reportValidity();
                });
                this.isSpinner = false;
                this.template.querySelector('c-mtp_-toast-message').showToast('error', "Please Enter Valid Reason!", 3000);
            } else {
                this.rejectedts = false;
                this.closeTimesheetModal();
                if (this.rejectreason != '' || this.rejectreason != undefined) {
                    rejereason = this.rejectreason;
                } else {
                    rejereason = '';
                }
                updateStaus({ action: action, tdId: tdid, rejectedreason: rejereason })
                    .then(result => {
                        let msg = result;
                        console.log({result});
                        if(msg == 'Timesheet updated Successfully!'){
                            this.template.querySelector('c-mtp_-toast-message').showToast('success', msg, 3000);
                        } else {
                            this.template.querySelector('c-mtp_-toast-message').showToast('error', msg, 3000);
                        }
                        this.getTimesheetList();
                    })
                    .catch(error => {
                        console.log({ error });
                        this.isSpinner = false;
                        this.template.querySelector('c-mtp_-toast-message').showToast('error', error, 3000);
                    });
            }
        }
        catch (error) {
            this.isSpinner = false;
            this.rejectedts = false;
            this.closeTimesheetModal();
            this.template.querySelector('c-mtp_-toast-message').showToast('error', error, 3000);
        }
    }

    submitevent(event) {
        this.submit = true;
    }

    openrejectpopup() {
        this.rejectedts = true;
        this.closeTimesheetModal();
    }

    closemodel(event) {
        if (event.target.dataset.name == 'Submit model') {
            this.submit = false;
        } else if (event.target.dataset.name == 'Reject Model') {
            this.rejectedts = false;
            this.isCreateTimesheetModalOpen = true;
        }
    }

    submitmethod(event) {
        this.submit = false;
        this.isSpinner = true;
        submittimesheet()
            .then(result => {
                this.getTimesheetList();
            })
            .catch(error => {
                console.log({ error });
                this.closeTimesheetModal();
            });
    }

    handleChangePopup(event) {
        try {
            if (event.target.name == 'PopupModalTask') {
                this.tsTask = event.target.value;
            } else if (event.target.name == 'PopupModalDescription') {
                this.tsTaskDescription = event.target.value;
            } else if (event.target.name == 'PopupModalDate') {
                this.tsDate = event.target.value;
            } else if (event.target.name == 'PopupModalStartTime') {
                this.tsStartTime = event.target.value;
                var totalminuts = parseInt(this.tsStartTime.substring(0, 2)) * 60 + parseInt(this.tsStartTime.substring(3, 5)) + 30;
                var end_time = this.NumToTime(totalminuts);
                var endd = end_time.split(":")[0].padStart(2, '0') + ":" + end_time.split(":")[1];
                var end = [];
                end = endd.split(':');
                var newend;

                console.log('StartTimeList===>',this.StartTimeList);
                console.log('totalminuts==>.',parseInt(this.tsStartTime.substring(0, 2)) * 60 * 3600);





                if (end[0] == '24') {
                    newend = '00';
                    this.tsEndTime = newend + ':' + end[1];
                }
                else {
                    this.tsEndTime = end_time.split(":")[0].padStart(2, '0') + ":" + end_time.split(":")[1];
                }
            } else if (event.target.name == 'PopupModalComments') {
                this.tsComments = event.target.value;
            } else if (event.target.name == 'PopupModalReject') {
                this.rejectreason = event.target.value;
            }
        } catch (error) {
            this.template.querySelector('c-mtp_-toast-message').showToast('error', error + "TSN0147", 3000);
        }
    }

    createTimesheet(event) {
        try {
            console.log('createTimesheet===>',{event});
            this.isSpinner = true;
            var name = event.target.dataset.name;
            console.log('%c Name >>'+name , 'background:green;');
            var currentdate = this.dateupadte(0);
            let dtv = parseInt(this.tsDate.substring(8, 10));
            if(dtv <= 9){
                dtv = dtv.toString().padStart(2, '0');
            }else {
                dtv = dtv;
            }
            var selecteddate = this.tsDate.substring(0, 4) + "-" + this.tsDate.substring(5, 7) + "-" + dtv;
            this.template.querySelectorAll('lightning-input').forEach(element => {
                element.reportValidity();
            });
            this.template.querySelectorAll('lightning-textarea').forEach(element => {
                element.reportValidity();
            });

            if (!this.tsDate && this.tsTaskDescription.trim().length == 0 && this.tsTask.trim().length == 0) {
                this.isSpinner = false;
                this.template.querySelector('c-mtp_-toast-message').showToast('error', "Don't Missing Required value to create Timesheet", 3000);
            }
            else if (this.tsStartTime.length == 0) {
                this.isSpinner = false;
                this.template.querySelector('c-mtp_-toast-message').showToast('error', "Don't Missing Required value to create Timesheet", 3000);
            } else if (currentdate != selecteddate && name != 'Update') {
                this.isSpinner = false;
                this.template.querySelector('c-mtp_-toast-message').showToast('error', "Please select Today's Date", 3000);
            }
            else if (this.tsTask.length == 0) {
                this.isSpinner = false;
                this.template.querySelector('c-mtp_-toast-message').showToast('error', "Don't Missing Required value to create Timesheet", 3000);
            }
            else if (this.tsTaskDescription.length == 0) {
                this.isSpinner = false;
                this.template.querySelector('c-mtp_-toast-message').showToast('error', "Don't Missing Required value to create Timesheet", 3000);
            }
            else if (currentdate == selecteddate) {
                if (name == 'Create') {
                    this.closeTimesheetModal();
                    this.timesheetwrap.taskname = this.tsTask;
                    this.timesheetwrap.taskdesc = this.tsTaskDescription;
                    this.timesheetwrap.taskdate = this.tsDate;
                    this.timesheetwrap.starttime = this.tsStartTime;
                    this.timesheetwrap.endtime = this.tsEndTime;
                    this.timesheetwrap.comments = this.tsComments;

                    var tswrap = JSON.stringify(this.timesheetwrap);
                    createTimesheetRecord({
                        timesheetdata: tswrap,
                        userid: USER_ID
                    })
                        .then(result => {
                            console.log({result})
                            this.tsTask = "";
                            this.tsTaskDescription = "";
                            this.tsDate = "";
                            this.tsStartTime = "";
                            this.tsEndTime = "";
                            this.tsComments = "";
                            if (result == 'Timesheet Created Successfully') {
                                this.template.querySelector('c-mtp_-toast-message').showToast('success', result, 3000);
                                this.getTimesheetList();
                            }
                            else {
                                this.isSpinner = false;
                                this.template.querySelector('c-mtp_-toast-message').showToast('error', result, 3000);
                            }
                        })
                        .catch(error => {
                            console.log('Error in Create Timesheet Record::>>',{ error });
                            this.closeTimesheetModal();
                            this.template.querySelector('c-mtp_-toast-message').showToast('error', error, 3000);
                            this.isSpinner = false;
                        });
                }
                else if (name == 'Update') {
                    this.timesheetwrap.taskname = this.tsTask;
                    this.timesheetwrap.taskdesc = this.tsTaskDescription;
                    this.timesheetwrap.taskdate = this.tsDate;
                    this.timesheetwrap.starttime = this.tsStartTime;
                    this.timesheetwrap.endtime = this.tsEndTime;
                    this.timesheetwrap.comments = this.tsComments;
                    var tswrap = JSON.stringify(this.timesheetwrap);

                    console.log('tswrap>>'+tswrap);
                    updateTimesheetDetailRecord({ timesheetdata: tswrap, timesheetdetailId: this.timesheetdetailId })
                        .then(result => {
                            console.log({ result });
                            this.closeTimesheetModal();
                            this.getTimesheetList();
                        })
                        .catch(error => {
                            console.log('Error in update Timesheet Detail Record==>',{ error });
                            this.closeTimesheetModal();
                            this.isSpinner = false;
                            this.template.querySelector('c-mtp_-toast-message').showToast('error', error, 3000);
                        });
                }
            }
            else{
                this.timesheetwrap.taskname = this.tsTask;
                this.timesheetwrap.taskdesc = this.tsTaskDescription;
                this.timesheetwrap.taskdate = this.tsDate;
                this.timesheetwrap.starttime = this.tsStartTime;
                this.timesheetwrap.endtime = this.tsEndTime;
                this.timesheetwrap.comments = this.tsComments;

                var tswrap = JSON.stringify(this.timesheetwrap);
                console.log('tswrap elsseš>>'+tswrap);
                console.log('this.timesheetdetailId >>'+this.timesheetdetailId);
                updateTimesheetDetailRecord({ timesheetdata: tswrap, timesheetdetailId: this.timesheetdetailId })
                    .then(result => {
                        console.log({ result });
                        this.closeTimesheetModal();
                        this.getTimesheetList();
                    })
                    .catch(error => {
                        console.log({ error });
                        this.closeTimesheetModal();
                        this.isSpinner = false;
                        this.template.querySelector('c-mtp_-toast-message').showToast('error', error, 3000);
                    });
            }
        } catch (error) {
            this.closeTimesheetModal();
            this.isSpinner = false;
            this.template.querySelector('c-mtp_-toast-message').showToast('error', error, 3000);
        }
    }

    prevclk() {
        try {
            var td = new Date(this.todaysDate);
            var sd = new Date(this.dateupadte(0));
            console.log('td==>',td.toString().substring(0,3));
            console.log('sd==>',sd);
            var test_date = td - sd;
            var dd = test_date / 86400000;
            var date_pre = this.dateupadte(dd - 1);
            this.todaysDate = date_pre;
            this.datevalue = date_pre.substring(8, 10) + '-' + date_pre.substring(5, 7) + '-' + date_pre.substring(0, 4);
            this.getTimesheetList();
        } catch (error) {
            this.template.querySelector('c-mtp_-toast-message').showToast('error', error, 3000);
        }
    }

    nextclk() {
        try {
            var td = new Date(this.todaysDate);
            var sd = new Date(this.dateupadte(0));
            var test_date = td - sd;
            var dd = test_date / 86400000;
            var date_pre = this.dateupadte(dd + 1);
            this.todaysDate = date_pre;
            this.datevalue = date_pre.substring(8, 10) + '-' + date_pre.substring(5, 7) + '-' + date_pre.substring(0, 4);
            this.getTimesheetList();
        } catch (error) {
            this.template.querySelector('c-mtp_-toast-message').showToast('error', error, 3000);
        }
    }

    loadwrapper() {
        this.timesheetwrap = {};
        this.timesheetwrap.taskname = '';
        this.timesheetwrap.taskdesc = '';
        this.timesheetwrap.taskdate = '';
        this.timesheetwrap.starttime = '';
        this.timesheetwrap.endtime = '';
        this.timesheetwrap.comments = '';
    }

    //Added to delete timesheet
    deleteTimesheet(event) {
        this.isSpinner = true;
        var timeId = event.target.dataset.id;
        deleteTimesheetRecord({ timesheetdetailId: timeId })
            .then(result => {
                this.getTimesheetList();
                this.template.querySelector('c-mtp_-toast-message').showToast('success', 'Timesheet deleted Successfully!', 3000);
            })
            .catch(error => {
                console.log({ error });
                this.isSpinner = false;
                this.template.querySelector('c-mtp_-toast-message').showToast('error', error, 3000);
            });

    }
}