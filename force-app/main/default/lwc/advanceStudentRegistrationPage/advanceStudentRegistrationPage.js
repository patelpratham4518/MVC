import { LightningElement, track, api } from 'lwc';
import getContact from '@salesforce/apex/QuestionsController.getContact';
import getAccount from '@salesforce/apex/QuestionsController.getAccount';
import creCon from '@salesforce/apex/QuestionsController.createContact';

export default class StudentRegistrationPage extends LightningElement {
    @api accountId;
    @api contactId;
    @track showspinner = false;
    @track submitdisable = true;
    @track candidateForm = true;
    @track registrationSucessfull = false;
    @track candidateExists = false;
    @track thankYouSection = false;
    @track newContact = true;
    @track accountName;
    @track displayNone = true;

    @track firstname='';
    @track lastname='';
    @track email='';
    @track enroll='';
    @track mobile='';
    gender='';
    department='';
    semester='';
    fileData = '';
    fileName = '';

    registeredEmail = '';
    registeredEnroll = '';

    genderOptions = [
        { label : 'Male', value: 'Male'},
        { label : 'Female', value: 'Female'}
    ];

    departmentOptions = [
        { label: 'Computer Engineering', value: 'Computer Engineering' },
        { label: 'Information Technology', value: 'Information Technology' },
        { label : 'Other', value: 'Other'}
    ];

    semesterOptions = [
        { label: 'Semester 1', value: '1' },
        { label: 'Semester 2', value: '2' },
        { label: 'Semester 3', value: '3' },
        { label: 'Semester 4', value: '4' },
        { label: 'Semester 5', value: '5' },
        { label: 'Semester 6', value: '6' },
        { label: 'Semester 7', value: '7' },
        { label: 'Semester 8', value: '8' },
    ];

    connectedCallback(event){
        this.showspinner = true;
        // window.location.replace("https://mvclouds.com/");
        console.log('contactId ==> '+this.contactId);
        if (this.accountId != null && this.accountId != '') {
            getAccount({accountId: this.accountId})
            .then(result => {
                if (result != null && result.Active__c == true) {
                    this.displayNone = false;
                    this.accountName = 'Placement Form For ' + result.Name;
                } else {
                    window.location.replace("https://mvclouds.com/");
                }
            })
            .catch(error => {
                console.log('error ==> ',error);
            });
        }
        if (this.contactId != null && this.contactId != '') {
            getContact({contactId: this.contactId})
            .then(result => {
                if (result.Enrollment_No__c != null && result.Enrollment_No__c != '') {
                    this.thankYouSection = true;
                    this.newContact = false;
                }
                this.firstname = result.FirstName;
                this.lastname = result.LastName;
                this.email = result.Email;
                this.mobile = result.MobilePhone;
                this.showspinner = false;
            })
            .catch(error => {
                this.contactId = null;
                this.showspinner = false;
                console.log('error ==> ',error);
            });
        } else{
            this.contactId = null;
            this.showspinner = false;
        }
    }

    handleChange(event){
        const field = event.target.name;
        var value = event.target.value;

        // console.log(field + ' => ' + value);

        if(field === 'firstname'){
            this.firstname = value;
        }
        if(field === 'lastname'){
            this.lastname = value;
        }
        if(field === 'email'){
            this.email = value;
        }
        if(field === 'enroll'){
            this.enroll = value;
        }
        if(field === 'mobile'){
            this.mobile = value;
        }
        if(field === 'department'){
            this.department = value;
        }
        if(field === 'semester'){
            this.semester = value;
        }
        if(field === 'Gender'){
            this.gender = value;
        }

        this.checkAllFields();
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        this.fileName = uploadedFiles[0].name;
        console.log('this.fileName ==> '+this.fileName);
        //check if the file size is greater than 3.5 MB
        if(uploadedFiles[0].size > 3500000){
            alert('File size should be less than 4 MB');
            this.fileName = '';
            return;
        }
        const reader = new FileReader();
        reader.onload = () => {
            const fileContents = reader.result;
            const base64 = 'base64,';
            this.fileData = fileContents.substr(fileContents.indexOf(base64) + base64.length);
        }
        reader.readAsDataURL(uploadedFiles[0]);
    }
        

    submituserdetails() {
        this.showspinner = true;
        creCon({contactId: this.contactId , firstname: this.firstname, lastname: this.lastname, email: this.email, enroll: this.enroll, mobile: this.mobile, department: this.department, semester: this.semester, gender: this.gender, resume: this.fileData, accId: this.accountId, sendMailBool: false})
        .then(result => {
            console.log('result ==> '+result);
            this.showspinner = false;
            if(result.includes('New Contact Created')){
                this.registrationSucessfull = true;
                this.registeredEmail = result.split('email')[1];
                this.registeredEnroll = result.split('number ')[1].split(' ')[0];
            }else if(result.includes('We already had contact')){
                this.candidateExists = true;
                this.registeredEmail = result.split('email ')[1].split(' ')[0];
                this.registeredEnroll = result.split('number ')[1].split(' ')[0];
            }else{
                alert('Something went wrong. Please try again.');
            }
        })
        .catch(error => {
            console.log('error ==> ',error);
            this.showspinner = false;
            alert('Something went wrong. Please try again.');
        });
    }

    checkAllFields(){
        this.firstname = this.firstname.trim();
        this.lastname = this.lastname.trim();
        this.email = this.email.trim();
        this.enroll = this.enroll.trim();
        this.mobile = this.mobile.trim();

        var emailRegex = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
        var nameRegex = /^[a-zA-Z ]+$/;
        var enrollRegex = /^[0-9]{10,15}$/;
        var mobileRegex = /^[0-9]{10,12}$/;

        if(this.firstname !== '' && this.lastname !== '' && this.email !== '' && this.enroll !== '' && this.mobile !== '' && this.department !== '' && this.semester !== '' && this.gender !== ''){
            if(nameRegex.test(this.firstname) && nameRegex.test(this.lastname) && emailRegex.test(this.email) && enrollRegex.test(this.enroll) && mobileRegex.test(this.mobile)){
                this.submitdisable = false;
            }else{
                this.submitdisable = true;
            }
        }else{
            this.submitdisable = true;
        }
    }

    openThankYouPage(){
        this.closeModal();
        this.thankYouSection = true;
    }

    closeModal(){
        this.registrationSucessfull = false;
        this.candidateExists = false;
    }

    removeFile(){
        this.fileName = '';
        this.fileData = '';
    }

}