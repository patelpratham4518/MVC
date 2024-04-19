import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import { getRecord } from 'lightning/uiRecordApi';
import homepage from '@salesforce/resourceUrl/homepage';
import course from '@salesforce/resourceUrl/course';
import timesheet from '@salesforce/resourceUrl/timesheet';
import leave from '@salesforce/resourceUrl/leave';
import calender from '@salesforce/resourceUrl/calender';
import arrow from '@salesforce/resourceUrl/arrow';

import checkuser from '@salesforce/apex/TimesheetController.checkuser';

export default class Mtp_HomePage extends NavigationMixin(LightningElement) {

    imgarrow = arrow;
    courseimg = course;
    timesheetimg = timesheet;
    leaveimg = leave;
    calenderimg = calender;
    @track username;
    userdetail;

    get imghome(){
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

    // Check USER is TRAINEE or MENTOR
     @wire(checkuser)
    wiredcheckuser({ error, data }) {
        if (data) {
            console.log({ data });
            this.userdetail = data;
        } else if (error) {
            console.log({error});
        }
    }

    
    navigation(event){
        console.log({event});
        let name = event.currentTarget.dataset.name;
        console.log({name});

        var pageapiname;
        var urlValue = '/s/';

        if(name == "course"){
            pageapiname = 'Course__c';
            urlValue += 'course';
        }else if(name == "timesheet"){
            console.log('this.userdetail==>',this.userdetail);
            if(this.userdetail == 'Trainee') {
                pageapiname = 'Timesheet__c';
                urlValue += 'timesheet';
            } else {
                pageapiname = 'TraineeDetail__c';
                urlValue += 'traineedetail';
            }
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
}