import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getContact from '@salesforce/apex/InterviewResultController.getContact';
import getAnswer from '@salesforce/apex/InterviewResultController.getAnswer';
import updateResult from '@salesforce/apex/InterviewResultController.updateResult';
import getCollege from '@salesforce/apex/InterviewResultController.getCollege';

export default class InterviewResult extends LightningElement {

    @track contactlst = [];
    @track showdetail = false;
    @track answerData = '';

    @track iserror = false;
    @track errormsg = '';

    @track selectedValue = '';
    @track isSpinner = true;
    // @track collegeOptions = [];
    @track collegeOptions = [{ label: 'ALL', value: 'ALL' }];

    connectedCallback(){
        // this.selectedValue = 'ALL'; // Set it to 'ALL' initially
        this.isSpinner = true;
        this.loadStudentsByCollege();
        this.loadColleges();
    }

    loadColleges() {
        getCollege()
            .then((result) => {
                console.log('result--==-->',result);
                if (result) {
                    this.isSpinner = false;
                    this.collegeOptions = [
                        ...this.collegeOptions,
                        ...result.map(college => ({
                            label: college.Name,
                            value: college.Name
                        }))
                    ];
                } else {
                    this.collegeOptions = [];
                }
            })
            .catch((error) => {
                console.error('Error:', error);
            });
    }

    handleSelection(event) {
        this.isSpinner = true;
        console.log('Change');
        this.selectedValue = event.detail.value;
        console.log('selectedValues--->',this.selectedValue);
        this.loadStudentsByCollege();
    }

    loadStudentsByCollege() {
        console.log('---loadStudentsByCollege---');
        getContact({ collegeName: this.selectedValue })
            .then((result) => {
                console.log('Contact result-->',result);
                this.isSpinner = false;
                if (result != null) {
                    this.manageContactData(result);
                }
            })
            .catch((error) => {
                console.error('Error:', error);
            });
    }

    manageContactData(data){
        let conObjList = [];
        data.forEach(element => {
            if (element.Answers__r != undefined && element.Answers__r != null) {
                let PracticalAnswer = 0
                if (element.Answers__r[0].Answer_1__c && element.Answers__r[0].Answer_1__c.trim() != '') {
                    PracticalAnswer += 1;
                }
                if (element.Answers__r[0].Answer_2__c && element.Answers__r[0].Answer_2__c.trim() != '') {
                    PracticalAnswer += 1;
                }
                if (element.Answers__r[0].Answer_3__c && element.Answers__r[0].Answer_3__c.trim() != '') {
                    PracticalAnswer += 1;
                }
                if (element.Answers__r[0].Answer_4__c && element.Answers__r[0].Answer_4__c.trim() != '') {
                    PracticalAnswer += 1;
                }
                if (element.Answers__r[0].Answer_5__c && element.Answers__r[0].Answer_5__c.trim() != '') {
                    PracticalAnswer += 1;
                }
                if (element.Answers__r[0].Answer_6__c && element.Answers__r[0].Answer_6__c.trim() != '') {
                    PracticalAnswer += 1;
                }

                var conObj = {
                    'Id': element.Id,
                    'Name': element.Name,
                    'College': element.College_Name__c,
                    'Email': element.Email,
                    'Description': element.Description,
                    'ErNo': element.Enrollment_No__c,
                    'AptitudeMarks': element.Answers__r[0].Aptitude_Marks__c,
                    'AptitudeResult': element.Answers__r[0].Aptitude_Result__c,
                    'PracticalAnswer': PracticalAnswer,
                    'PracticalResult': element.Answers__r[0].Practical_Result__c,
                };
                conObjList.push(conObj);
            } else {
                var conObj = {
                    'Id': element.Id,
                    'Name': element.Name,
                    'College': element.College_Name__c,
                    'Email': element.Email,
                    'Description': element.Description,
                    'ErNo': element.Enrollment_No__c,
                    'AptitudeMarks': '-',
                    'AptitudeResult': '-',
                    'PracticalAnswer': '-',
                    'PracticalResult': '-',
                };
                conObjList.push(conObj);
            }
        });
        this.contactlst = conObjList;
    }

    detailclk(event) {
        let conid = event.currentTarget.dataset.id;
        console.log({conid});
        this.getAnswer(conid);
    }

    getAnswer(contactId) {
        getAnswer({ contId : contactId })
            .then((result) => {
                console.log('Result of Answer-->',{result});
                if(result != null) {
                    this.showdetail = true;
                    this.answerData = result;
                } else {
                    this.iserror = true;
                    this.errormsg = 'No Data Available';
                    setTimeout(() => {
                        this.iserror = false;
                    }, 1000);
                }
            })
            .catch((error) => {
                console.log('Error ===>',{error});
            });
    }

    onbtnclk(event) {
        let btnname = event.currentTarget.dataset.name;
        let ansid = event.currentTarget.dataset.id;
        updateResult({ answerId : ansid, resultval : btnname, collegeName: this.selectedValue })
            .then((result) => {
                if (result != null) {
                    this.manageContactData(result);
                }
                this.closeModal();
            })
            .catch((error) => {
                console.log('Error ===>',{error});
            });
    }

    closeModal() {
        this.showdetail = false;
    }

    ShowToast(title, message, variant) {
        try{
            const evt = new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            });
            this.dispatchEvent(evt);
        }
        catch(error){
            console.log('Error in ShowToastEvent-->',{error});
        }
    }
}