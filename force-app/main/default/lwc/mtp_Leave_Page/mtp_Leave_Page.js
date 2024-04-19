import { LightningElement, api, track, wire } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import { getRecord } from 'lightning/uiRecordApi';
import middleflight from '@salesforce/resourceUrl/mtp_leaveflighticon';
import createleave from '@salesforce/apex/LeaveController.createleave';
import { NavigationMixin } from 'lightning/navigation';


export default class Mtp_Leave_Page extends NavigationMixin(LightningElement) {
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

    applyleave() {
        console.log('applyleave');
        // console.log(this.dayval!= undefined &&  this.mentorval!= undefined && this.reasonval!= undefined && this.dayval!= '' &&  this.mentorval!= '' && this.reasonval!= '');
        if (this.startval != undefined && this.startval != '' && this.endval != undefined && this.endval != '' && this.dayval != undefined && this.mentorval != undefined && this.reasonval != undefined && this.dayval != '' && this.mentorval != '' && this.reasonval != '') {
            createleave({ Startdate: this.startval, Enddate: this.endval, Daytype: this.dayval, Mentor: this.mentorval, Reason: this.reasonval })
                .then(result => {
                    console.log({ result });
                    console.log(this.endval + '---' + this.startval);
                    if (result == 'Success') {
                        this.template.querySelector('c-mtp_-toast-message').showToast('success', 'Leave applied Successfully!!', 3000);
                        setTimeout(() => {

                            var nameValue = 'Leave__c';
                            var urlValue = '/s/';
                            urlValue += 'leave';
                            this[NavigationMixin.Navigate]({
                                type: 'comm__namedPage',
                                attributes: {
                                    name: nameValue,
                                    url: urlValue
                                },

                            });
                        }, 2000);

                    } else {
                        this.template.querySelector('c-mtp_-toast-message').showToast('error', 'Something went wrong!!', 3000);
                    }

                })
                .catch(error => {
                    console.log({ error });
                });

        } else if (this.startval == undefined || this.startval == '' || this.endval == undefined || this.endval == '') {
            this.template.querySelector('c-mtp_-toast-message').showToast('error', 'Uh oh, Please Select Date !!', 3000);
        } else if (this.dayval == undefined || this.dayval == '') {
            this.template.querySelector('c-mtp_-toast-message').showToast('error', 'Uh oh, Please Select Day Type !!', 3000);
        } else if (this.mentorval == undefined || this.mentorval == '') {
            this.template.querySelector('c-mtp_-toast-message').showToast('error', 'Uh oh, Please Select Your Mentor !!', 3000);
        } else if (this.reasonval == undefined || this.reasonval == '') {
            this.template.querySelector('c-mtp_-toast-message').showToast('error', 'Uh oh, Please Give Reason for Leave !!', 3000);
        }

    }
    cancelLeave() {
        var nameValue = 'Leave__c';
        var urlValue = '/s/';
        urlValue += 'leave';
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: nameValue,
                url: urlValue
            },

        });
    }
}