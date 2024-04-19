import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';           
import { RefreshEvent } from 'lightning/refresh';
import getJobApplication from '@salesforce/apex/scheduleInterviewController.getJobApplication';
import createInterviewRecord from '@salesforce/apex/scheduleInterviewController.createInterviewRecord';
const TIMEOUT_DURATION = 300;

export default class ScheduleInterviewFromContact extends NavigationMixin(LightningElement) {

    @api recordId;
    @track isSpinner = false;
    @track showSecondModal = false;
    @track isNextButtonDisabled = true;
    @track jobApplicationId;
    @track contactIdFromFirstModal;
    @track jobPostingValueFromFirstModal;
    @track jobPostingValue;
    @track timeValue;
    @track dateValue;
    @track Meetinglink = false;
    @track Interviewer;
    @track RoundName;
    @track disableSubmit = false;
    options = [
        { label: 'First', value: 'First' },
        { label: 'Second', value: 'Second' },
        { label: 'Final', value: 'Final' },
    ];
    
    connectedCallback(){
        this.isSpinner = true;
        setTimeout(() => {
            this.showModalBox();
        }, TIMEOUT_DURATION);
    }

    showModalBox() {
        getJobApplication({ contactId: this.recordId })
            .then(result => {
                if (result) {
                    // Job application exists, display the second modal
                    this.showSecondModal = true;
                    this.jobApplicationId = result.Id;
                    this.jobPostingValue = result.Job_Posting__c;
                    this.isSpinner = false;
                } else {
                    // No job application found, display the first modal
                    this.showSecondModal = false;
                    this.isSpinner = false;
                }
            })
            .catch(error => {
                this.isSpinner = false;
                console.error('Error fetching job application', error);
                this.ShowToast('error', 'Error', 'An error occurred while checking for Job Application.');
            });
    }

    closeModal() {
        this.dispatchEvent(new RefreshEvent());
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleJobPostingChange(event) {
        this.jobPostingValueFromFirstModal = event.target.value;
        console.log(this.jobPostingValueFromFirstModal);
        this.isNextButtonDisabled = !this.jobPostingValueFromFirstModal;
    }

    handleRecordSave(event) {
        this.contactIdFromFirstModal = this.recordId;
        if (!this.showSecondModal) {
            this.template.querySelector('lightning-record-edit-form').submit(this.fields);
        }

        this.jobPostingValue = this.jobPostingValueFromFirstModal;

        this.ShowToast('success', 'Success', 'Job Application Created');
        this.dispatchEvent(new RefreshEvent());

        this.showSecondModal = true;
    }

    handleFirstModalSuccess(event) {
        this.jobApplicationId = event.detail.id;
        this.jobPostingValue = this.jobPostingValueFromFirstModal;
        this.showSecondModal = true;
    }

    handlePicklistChange(event) {
        this.RoundName = event.detail.value;
    }  

    handleSecondModalSuccess(event) {
        this.ShowToast('success', 'Success', 'Interview Created Successfully');
    }

    LinkChange(event) {
        if (this.Meetinglink === true) {
            this.Meetinglink = false;
        } else {
            this.Meetinglink = true;
        }
    }

    InterviewerChange(event) {
        this.Interviewer = event.target.value;
    }

    timeChange(event) {
        this.timeValue = event.detail.value;
    }

    dateChange(event) {
        this.dateValue = event.target.value;
    }

    handleSubmit(event) {
        this.disableSubmit = true;
        if (!this.RoundName || !this.Interviewer || !this.timeValue || !this.dateValue) {
            this.ShowToast('error', 'Error Creating Interview', 'Please fill in all required fields.');
            this.disableSubmit = false;
        } else {
            // Parse the time input into hours and minutes
            const timeParts = this.timeValue.split(':');
            const hours = parseInt(timeParts[0]);
            const minutes = parseInt(timeParts[1]);

            // Check if the time is between 10 am and 8 pm
            if (hours < 10 || (hours === 10 && minutes < 0) || hours > 20) {
                // Time is outside the allowed range
                this.ShowToast('error', 'Error Creating Interview', 'Interview time should be between 10 am and 8 pm.');
                this.disableSubmit = false;
            } else {
                this.isSpinner = true;
                // Time is within the allowed range, proceed with creating the interview record
                createInterviewRecord({
                    jobApplicationId: this.jobApplicationId,
                    contactId: this.recordId,
                    jobPostingId: this.jobPostingValue,
                    meetingLink: this.Meetinglink,
                    roundName: this.RoundName,
                    interviewerId: this.Interviewer,
                    TimeOfInterview: this.timeValue,
                    DateofInterview: this.dateValue
                })
                    .then(result => {
                        console.log(result);
                        this.redirectToInterview(result);
                        this.timeValue = '';
                        this.dateValue = '';
                        this.Meetinglink = false;
                        this.RoundName = '';
                        this.Interviewer = '';
                        this.isSpinner = false;
                        this.disableSubmit = false;
                        this.ShowToast('success', 'Success', 'Interview Created');
                    })
                    .catch(error => {
                        this.isSpinner = false;
                        this.disableSubmit = false;
                        console.log(error);
                        this.ShowToast('error', 'Error Creating Interview', 'An error occurred while creating the interview record.');
                    });
            }
        }
    }

    redirectToInterview(interview){
        this.dispatchEvent(new CloseActionScreenEvent());
        this[NavigationMixin.Navigate]({
            type:'standard__recordPage',
            attributes:{
                "recordId":interview.Id,
                "objectApiName":"Interview__c",
                "actionName": "view"
            }
        });
    }

    // Custom Toast Message
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