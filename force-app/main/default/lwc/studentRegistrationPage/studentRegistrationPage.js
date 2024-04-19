import { LightningElement, track, api } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

import creCon from '@salesforce/apex/QuestionsController.createContact';

export default class StudentRegistrationPage extends LightningElement {
    @api accountId;
    @track showspinner = false;
    @track submitdisable = true;
    @track candidateForm = true;
    @track registrationSucessfull = false;
    @track candidateExists = false;
    regContactForm = {};  

    firstname='';
    lastname='';
    email='';
    enroll='';
    mobile='';
    department='';
    semester='';
    fileData = '';
    openfileUpload(event){
        const file = event.target.files[0]
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            this.fileData = {
                'filename': file.name,
                'base64': base64,
                'recordId': this.recordId
            }
            console.log(this.fileData)
        }
        reader.readAsDataURL(file)
    }   
    fileName = '';

    registeredEmail = '';
    registeredEnroll = '';

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


    handleChange(event){
        const field = event.target.name;
        var value = event.target.value;

        // console.log('field-->'+field);
        // console.log('value-->'+value);

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

        this.checkAllFields();
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        this.fileName = uploadedFiles[0].name;
        console.log('this.fileName-->'+this.fileName);
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
        creCon({firstname: this.firstname, lastname: this.lastname, email: this.email, enroll: this.enroll, mobile: this.mobile, department: this.department, semester: this.semester, resume: this.fileData, accId: this.accountId, sendMailBool: true})
        .then(result => {
            console.log('result-->'+result);
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
        }
        )
        .catch(error => {
            console.log('error-->'+error);
            this.showspinner = false;
            alert('Something went wrong. Please try again.');
        }
        );
    }

    checkAllFields(){
        this.firstname = this.firstname.trim();
        this.lastname = this.lastname.trim();
        this.email = this.email.trim();
        this.enroll = this.enroll.trim();
        this.mobile = this.mobile.trim();

        var emailRegex = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
        var nameRegex = /^[a-zA-Z ]+$/;
        var enrollRegex = /^[0-9]{12,15}$/;
        var mobileRegex = /^[0-9]{10,12}$/;

        if(this.firstname !== '' && this.lastname !== '' && this.email !== '' && this.enroll !== '' && this.mobile !== '' && this.department !== '' && this.semester !== ''){
            if(nameRegex.test(this.firstname) && nameRegex.test(this.lastname) && emailRegex.test(this.email) && enrollRegex.test(this.enroll) && mobileRegex.test(this.mobile)){
                this.submitdisable = false;
            }else{
                this.submitdisable = true;
            }
        }else{
            this.submitdisable = true;
        }
    }

    reloadPage(){
        window.location.reload();
    }

    removeFile(){
        this.fileName = '';
        this.fileData = '';
    }


}