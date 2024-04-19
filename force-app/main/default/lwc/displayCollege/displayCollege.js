import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Site_URL from '@salesforce/label/c.Site_URL';
import getColleges from '@salesforce/apex/CollegeController.getColleges';
import createCollege from '@salesforce/apex/CollegeController.createCollege';
import deleteCollege from '@salesforce/apex/CollegeController.deleteCollege';
import getStudents from '@salesforce/apex/CollegeController.getStudents';
import updateAccount from "@salesforce/apex/CollegeController.updateAccount";
import sendEmail from "@salesforce/apex/CollegeController.sendEmail";

export default class DisplayCollege extends LightningElement {
    @track colleges = [];
    @track showCollegeList = true;
    @track isSpinner = true;

    @track newCollegePopup = false;
    @track confirmPopup = false;
    @track emailPopup = false;
    @track confirmSchedulePopup = false;
    @track disableSchedule = false;
    @track displayTestEmailBtn = false;
    
    @track newCollegeName = '';
    @track collegeDetails;
    
    @track examDateTime;
    @track registerEmail;
    @track reminderEmail;
    @track examLinkEmail;
    
    activeOptions = [
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' },
    ];

    // Define columns for the datatable
    columns = [
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { label: 'Active', fieldName: 'Active__c', type: 'checkbox'},
        { 
            label: 'Exam Date Time', 
            fieldName: 'Exam_Date_Time__c', 
            type: 'date',
            typeAttributes: {
                year: "numeric",
                month: "long",
                day: "2-digit",
                hour: "2-digit",
                minute: "2-digit"
            }
        },
        {
            type: "button", label: 'Copy Link', initialWidth: 150, typeAttributes: {
                label: 'Copy Link',
                name: 'Copy Link',
                title: 'Copy Link',
                disabled: false,
                value: 'Copy Link',
                iconPosition: 'left',
                iconName:'utility:copy',
                variant:'Brand',
            },
        },
        {
            type: "button", label: 'Details', initialWidth: 150, typeAttributes: {
                label: 'Details',
                name: 'View',
                title: 'View',
                disabled: false,
                value: 'view',
                iconPosition: 'left',
                iconName:'utility:preview',
                variant:'Brand',
            },
        },
        {
            type: "button", label: 'Delete', initialWidth: 130, typeAttributes: {
                label: 'Delete',
                name: 'Delete',
                title: 'Delete',
                disabled: false,
                value: 'delete',
                variant:'destructive',
            },
        },
    ];

    contactColumns = [
        { label: 'Name', fieldName: 'FullName__c', type: 'text'},
        { label: 'Enrollment no.', fieldName: 'Enrollment_No__c', type: 'text'},
        { label: 'Email', fieldName: 'Email', type: 'email'},
        { label: 'Phone', fieldName: 'MobilePhone', type: 'phone'},
        { label: 'Semester', fieldName: 'Semester__c', type: 'text'}
    ];

    connectedCallback(){
        this.getCollegedata();
    }

    getCollegedata(){
        this.isSpinner = true;
        getColleges()
        .then(result => {
            console.log('Colleges ==> ',result);
            this.colleges = result;
            this.isSpinner = false;
        })
        .catch(error => {
            console.log('Error ==> ',error);
            this.ShowToast('Error', 'Error', 'Something Went Wrong!!!');
            this.isSpinner = false;
        });
    }

    callRowAction(event) {
        this.collegeDetails = event.detail.row;
        let actionName = event.detail.action.name;

        if (actionName == 'Copy Link'){
            let formLink = Site_URL + 'advanceStudentRegistrationPage?College_Id=' + this.collegeDetails.Id;
            navigator.clipboard.writeText(formLink);
            this.ShowToast('Success', 'Copied Successfully', 'Student registation link is copied successfully');
        }

        if (actionName == 'View') {
            if (this.collegeDetails.Exam_Date_Time__c != null) {
                let dt = new Date(this.collegeDetails.Exam_Date_Time__c);
                this.examDateTime = {date: dt.toISOString().slice(0, 10), time: dt.toTimeString().slice(0,8)};
            } else {
                this.examDateTime = {date: '', time: ''};
            }
            
            this.showCollegeList = false;
            this.isSpinner = true;
            getStudents({collegeId: this.collegeDetails.Id})
            .then((data)=>{
                this.contacts = data;
                this.isSpinner = false;
            })
            .catch((error)=>{
                console.log('Error ==> ',error);
                this.isSpinner = false;
            });
            this.registerEmail = this.collegeDetails.Registration_Email_Template__c;
            this.reminderEmail = this.collegeDetails.Exam_Reminder_Template__c;
            this.examLinkEmail = this.collegeDetails.Exam_Link_Template__c;
        }
        
        if (actionName == 'Delete'){
            this.confirmPopup = true;
        }
    }
    
    closeConfirmPopup(){
        this.confirmPopup = false;
    }

    displayCollegeList(){
        this.showCollegeList = true;
    }

    deleteCollegeRec(){
        this.isSpinner = true;
        deleteCollege({collegeid: this.collegeDetails.Id})
        .then(result => {
            this.colleges = result;
            this.ShowToast('Success', 'Success' , 'College deleted successfully');
            this.isSpinner = false;
        })
        .catch(error => {
            console.log('Error ==> ',error);
            this.ShowToast('Error', 'Error', 'Something Went Wrong!!!');
            this.isSpinner = false;
        })
        this.confirmPopup = false;
    }

    // Open the modal
    openModal() {
        this.newCollegePopup = true;
    }
    
    // Close the modal
    closeModal() {
        this.newCollegePopup = false;
    }

    sendEmail(){
        this.emailPopup = false;
        var emailAdd = this.template.querySelector(`[data-id="email"]`).value;
        var eTemplate = this.template.querySelector(`[data-id="tabset"]`).activeTabValue;
        var temp = {};
        if(eTemplate == 'register'){
            temp.subject = 'MV Clouds - Placement Registration';
            temp.body = this.registerEmail;

        } else if (eTemplate == 'reminder') {
            temp.subject = 'MV Clouds - Exam Reminder';
            temp.body = this.reminderEmail;

        } else if (eTemplate == 'exam') {
            temp.subject = 'MV Clouds - Unique Link to start your test'
            temp.body = this.examLinkEmail;
        }

        let examDate = new Date(this.template.querySelector(`[data-id="date"]`).value);
        let examTime = this.template.querySelector(`[data-id="time"]`).value;

        let tempStartTime = new Date('1970-01-01T' + examTime);
        let tempEndTime = new Date('1970-01-01T' + examTime);
        tempEndTime = new Date(tempEndTime.setHours(tempEndTime.getHours() + 2));

        let formattedExamDate = examDate.toLocaleDateString('en-US', { day: 'numeric', month: 'long', year: 'numeric' });
        let formattedStartTime = tempStartTime.toLocaleTimeString('en-US', {hour: 'numeric', minute: '2-digit', hour12: true});
        let formattedEndTime = tempEndTime.toLocaleTimeString('en-US', {hour: 'numeric', minute: '2-digit', hour12: true});

        temp.body = temp.body.replaceAll("{Exam_Date}", formattedExamDate);
        temp.body = temp.body.replaceAll("{Exam_StartTime}", formattedStartTime);
        temp.body = temp.body.replaceAll("{Exam_EndTime}", formattedEndTime);

        if (!/^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/.test(emailAdd)) {
            this.ShowToast('Error', 'Invalid Email', 'Enter a valid email address');
        } else {
            sendEmail({email: emailAdd, subject: temp.subject, body: temp.body})
            .then(result => {
                console.log('result ==> ',result);
                this.ShowToast('Success', 'Email sent', 'The email has been sent successfully');
                console.log(result);
            }).catch(error => {
                console.log('Error ==> ',error);
                this.ShowToast('Error', 'Error', 'Something Went Wrong!!!');
            })
        }
    }

    // On changing tabs
    handleTabs() {
        let selectedTab = this.template.querySelector(`[data-id="tabset"]`).activeTabValue;
        if(selectedTab == 'register'){
            if (this.template.querySelector(`[data-id="register"]`).innerHTML == '') {
                this.template.querySelector(`[data-id="register"]`).innerHTML = this.collegeDetails.Registration_Email_Template__c;
            }
            this.registerEmail = this.template.querySelector(`[data-id="register"]`).innerHTML;
            this.displayTestEmailBtn = true;
        } 
        else if (selectedTab == 'reminder') {
            if (this.template.querySelector(`[data-id="reminder"]`).innerHTML == '') {
                this.template.querySelector(`[data-id="reminder"]`).innerHTML = this.collegeDetails.Exam_Reminder_Template__c;
            }
            this.reminderEmail = this.template.querySelector(`[data-id="reminder"]`).innerHTML;
            this.displayTestEmailBtn = true;
        } 
        else if (selectedTab == 'exam') {
            if (this.template.querySelector(`[data-id="exam"]`).innerHTML == '') {
                this.template.querySelector(`[data-id="exam"]`).innerHTML = this.collegeDetails.Exam_Link_Template__c;
            }
            this.examLinkEmail = this.template.querySelector(`[data-id="exam"]`).innerHTML;
            this.displayTestEmailBtn = true;
        } 
        else {
            this.displayTestEmailBtn = false;
        }
    }

    openSchedulePopup(){
        let examTime = this.template.querySelector(`[data-id="time"]`).value;  
        let timeParts = examTime.split(':');
        let hours = parseInt(timeParts[0]);
        if (hours < 9 || hours > 20) {
            this.ShowToast('Error', 'Error', 'Exam time should be between 9 AM and 8 PM');
            this.disableSubmit = false;
        } else {
            this.confirmSchedulePopup = true;
        }
    }

    closeSchedulePopup(){
        this.confirmSchedulePopup = false;
    }

    // Schedule batch button
    handleSchedule(){
        this.confirmSchedulePopup = false;
        this.isSpinner = true;
        let examDate = this.template.querySelector(`[data-id="date"]`).value;
        let examTime = this.template.querySelector(`[data-id="time"]`).value;        
        let examDateTime = new Date(examDate + 'T' + examTime);
        examDateTime = examDateTime.getTime(); 

        // Update Account
        if (examTime == '' || examTime == null || examDate == '' || examDate == null){
            this.ShowToast('Error', 'Empty fields', 'Please fill all fields');
            this.isSpinner = false;
        } else if (examDate < new Date().toISOString().slice(0, 10)) {
            this.ShowToast('Error', 'Past date', 'Date cannot be of past');
            this.isSpinner = false;
        } else {
            examDate = new Date(examDate);
            let tempStartTime = new Date('1970-01-01T' + examTime);
            let tempEndTime = new Date('1970-01-01T' + examTime);
            tempEndTime = new Date(tempEndTime.setHours(tempEndTime.getHours() + 2));
    
            let formattedExamDate = examDate.toLocaleDateString('en-US', { day: 'numeric', month: 'long', year: 'numeric' });
            let formattedStartTime = tempStartTime.toLocaleTimeString('en-US', {hour: 'numeric', minute: '2-digit', hour12: true});
            let formattedEndTime = tempEndTime.toLocaleTimeString('en-US', {hour: 'numeric', minute: '2-digit', hour12: true});

            this.registerEmail = this.registerEmail.replaceAll("{Exam_Date}", formattedExamDate);
            this.registerEmail = this.registerEmail.replaceAll("{Exam_StartTime}", formattedStartTime);
            this.registerEmail = this.registerEmail.replaceAll("{Exam_EndTime}", formattedEndTime);

            this.reminderEmail = this.reminderEmail.replaceAll("{Exam_Date}", formattedExamDate);
            this.reminderEmail = this.reminderEmail.replaceAll("{Exam_StartTime}", formattedStartTime);
            this.reminderEmail = this.reminderEmail.replaceAll("{Exam_EndTime}", formattedEndTime);

            updateAccount({accId: this.collegeDetails.Id, dtime: examDateTime, registerEmail: this.registerEmail, reminderEmail: this.reminderEmail, examLink: this.examLinkEmail})
            .then(result => {
                this.disableSchedule = true;
                this.ShowToast('Success', 'Success', 'Batch class scheduled');
                this.displayCollegeList();
                this.getCollegedata();
            }).catch(error => {
                console.log('Error ==> ',error);
                this.ShowToast('Error', 'Error', 'Something Went Wrong');
                this.isSpinner = false;
            });
        }
    }

    handleEmail(){
        this.emailPopup = true;
    }

    closeEmailPopup(){
        this.emailPopup = false;
    }

    // Handle input changes and update newCollege properties
    handleInputChange(event) {
        this.newCollegeName = event.target.value;
    }

    // Implement logic to save the new college using Apex method
    saveCollege() {
        this.isSpinner = true;
        createCollege({ name: this.newCollegeName})
        .then(result => {
            this.colleges = result;
            // this.getCollegedata();
            this.ShowToast('Success', 'Success' , 'College Inserted Successfully');
            this.isSpinner = false;
            this.newCollegeName = '';
        })
        .catch(error => {
            console.log('Error ==> ',error);
            this.ShowToast('Error', 'Error', 'Something Went Wrong!!!');
            this.isSpinner = false;
        })
        this.newCollegePopup = false;
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
// MV Clouds - Placement Registration
// MV Clouds - Exam Reminder
// MV Clouds - Unique Link to start your test