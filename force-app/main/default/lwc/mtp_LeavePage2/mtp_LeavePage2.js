import { LightningElement, api, track, wire } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import { getRecord } from 'lightning/uiRecordApi';
import middleflight from '@salesforce/resourceUrl/mtp_leaveflighticon';

import allLeavesList from '@salesforce/apex/LeaveController.allLeavesList';

export default class Mtp_LeavePage2 extends LightningElement {
    @api recordId;
    leaveTypevalue;
    dayTypevalue;
    informvalue;
    flighticon = middleflight;
    @track username;
    @track dayval;
    @track mentorval;
    @track reasonval = '';
    @track startval;
    @track endval;

    @track pendingLeaves = [];
    @track approvedLeavesCount = 0;
    @track pendingLeavesCount = 0;
    @track rejectedLeavesCount = 0;

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.username = data.fields.Name.value;
        }
    }

    get leaveTypeOption() {
        return [
            { label: 'Loss of pay', value: 'Loss of pay' },
            { label: 'Optional', value: 'Optional' },
        ];
    }
    get dayTypeOption() {
        return [
            { label: 'Full', value: 'Full' },
            { label: 'First Half', value: 'First Half' },
            { label: 'Second Half', value: 'Second Half' },
        ];
    }
    get informOption() {
        return [
            { label: 'Devansh', value: 'Devansh' },
            { label: 'Karan', value: 'Karan' },
            { label: 'Nishit', value: 'Nishit' },
            { label: 'Prakash', value: 'Prakash' },
            { label: 'Ravi', value: 'Ravi' },
            { label: 'Ritu', value: 'Ritu' },
            { label: 'Yash', value: 'Yash' },
        ];
    }

    handleChange(event) {

        var selval = event.target.dataset.name;
        console.log({ selval });
        if (selval == 'radio') {
            this.dayval = event.target.value;
        } else if (selval == 'mentor') {
            this.mentorval = event.target.value;
        } else if (selval == 'reason') {
            this.reasonval = event.target.value;
        } else if (selval == 'start') {
            this.startval = event.target.value;
        } else if (selval == 'end') {
            this.endval = event.target.value;
        }
        console.log('dayval-->', this.dayval);
        console.log('mentorval-->', this.mentorval);
        console.log('reasonval-->', this.reasonval);
        console.log('startval-->', this.startval);
        console.log('endval-->', this.endval);
    }

    connectedCallback() {
        try {
            this.getAllLeavesList();
        } catch (error) {
            console.log({ error });
        }
    }

    getAllLeavesList() {
        console.log('in the getPendingLeavesList');
        try {
            // this.isSpinner = true;
            allLeavesList()
                .then(result => {
                    this.pendingLeaves = result;
                    console.log({ result });
                    var approvedCount = 0;
                    var rejectedCount = 0;
                    var pendingCount = 0;

                    for (const res of result) {
                        var sd = new Date(res.Start_Date__c);
                        var ed = new Date(res.End_Date__c);
                        res["startDateSTR"] = sd.toString().substring(0, 15);
                        res["endDateSTR"] = ed.toString().substring(0, 15);
                        var statusTag = '';
                        if (res.Status__c == 'Pending for Approval') {
                            statusTag = 'Pending for Approval';
                            pendingCount += 1;
                        } else if (res.Status__c == 'Approved') {
                            statusTag = 'Approved';
                            approvedCount += 1;
                        } else if (res.Status__c == 'Rejected') {
                            statusTag = 'Rejected';
                            rejectedCount += 1;
                        }
                        res["statusTag"] = statusTag;

                    }
                    this.approvedLeavesCount = approvedCount;
                    this.pendingLeavesCount = pendingCount;
                    this.rejectedLeavesCount = rejectedCount;

                    // this.endSpinner();
                })
                .catch(error => {
                    console.log({ error });
                    // this.endSpinner();
                });
        } catch (error) {
            console.log({ error });
            // this.endSpinner();
        }
    }
}