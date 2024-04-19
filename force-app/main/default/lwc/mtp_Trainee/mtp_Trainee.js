import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import { getRecord } from 'lightning/uiRecordApi';
import homepage from '@salesforce/resourceUrl/MVTrainee';
import course from '@salesforce/resourceUrl/course';
import timesheet from '@salesforce/resourceUrl/timesheet';
import leave from '@salesforce/resourceUrl/leave';
import calender from '@salesforce/resourceUrl/calender';
import arrow from '@salesforce/resourceUrl/arrow';

import gettraineelist from '@salesforce/apex/TraineeController.gettraineelist';

export default class Mtp_Trainee extends NavigationMixin(LightningElement) {

    imgarrow = arrow;
    courseimg = course;
    timesheetimg = timesheet;
    leaveimg = leave;
    calenderimg = calender;
    @track username;
    @track traineelst;

    get imghome() {
        return `background-image:url(${homepage})`;
    }

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

    connectedCallback() {
        this.getTrainee();
    }

    getTrainee() {

        gettraineelist() 
            .then(result => {
                console.log({ result });
                this.traineelst = result;
            })
            .catch(error => {
                console.log({ error });
            });
    }

    navigation(event){
        console.log({event});
        let conid = event.currentTarget.dataset.name;
        console.log({conid});

        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Timesheet__c',
                url: '/s/timesheet'
            },
            state: {
                recordId: conid,
            }
        });
    }
}