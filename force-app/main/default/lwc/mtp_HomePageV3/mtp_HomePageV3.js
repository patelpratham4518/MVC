import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import { getRecord } from 'lightning/uiRecordApi';
import timesheet from '@salesforce/resourceUrl/timesheet';
import calender from '@salesforce/resourceUrl/calender';
import arrow from '@salesforce/resourceUrl/arrow';

export default class Mtp_HomePageV3 extends NavigationMixin(LightningElement) {

    imgarrow = arrow;
    timesheetimg = timesheet;
    calenderimg = calender;
    @track username;
    @track isSpinner = false;

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
            var pageapiname = 'Timesheet__c';
            var urlValue = '/s/timesheet';
    
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

}