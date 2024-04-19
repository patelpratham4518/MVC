import { LightningElement, track } from 'lwc';
import getContactList from '@salesforce/apex/CodeRepositoryController.getCodeList';
import getPicklistLabelName from '@salesforce/apex/CodeRepositoryController.getPicklistLabelName';
import getCodeFileds from '@salesforce/apex/CodeRepositoryController.getCodeFileds';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



export default class CodeRepository extends LightningElement {

    @track currentStep = '1';
    @track codesRecord;
    @track codesRecordClone;
    @track searchValue = '';
    @track selectedValue = 'All';
    @track activeTab = '1';
    @track codeShareCodeId;
    @track codeFileData;
    @track iconName = 'utility:copy';
    @track altText = 'Copy Text';
    @track optionsList = [];
    @track codeLabel = '';
    @track description = '';

    connectedCallback() {
        this.getPicklistValues();
        this.handleSearchKeyword();
    }

    handleSearchKeyword() {
        console.log('this.searchValue--->', this.searchValue);

        getContactList()
            .then(result => {
                console.log('result--->' + result);
                console.log({result});
                // set @track contacts variable with return contact list from server  
                this.codesRecord = result;
                this.codesRecordClone = result;

                console.log('this.codesRecordClone---->', this.codesRecordClone);
            })
            .catch(error => {
                this.showToastMessage("error", "error", "Something went Wrong");
                this.codesRecord = null;
            });
    }


    get isStepOne() {
        return this.currentStep === "1";
    }

    get isStepTwo() {
        return this.currentStep === "2";
    }

    get isEnableNext() {
        return this.currentStep != "2";
    }

    get isEnablePrev() {
        return this.currentStep != "1";
    }

    get isEnableFinish() {
        return this.currentStep === "2";
    }

    handleOnStepClick(event) {
        this.currentStep = event.target.value;
    }

    handleNext() {
        if (this.currentStep == "1") {
            this.currentStep = "2";
        }
    }

    handlePrev() { 
        if (this.currentStep = "2") {
            this.currentStep = "1";
        }
    }

    handleFinish() {

    }

    // JS functions start 
    handleActive(event) {
        this.activeTab = event.target.value;
    }

    // update searchValue var when input field value change
    searchKeyword(event) {
        console.log('searchKeyword--->');
        this.searchValue = event.target.value;
        this.codesRecord = this.customFilter();
        console.log('this.codesRecord ==> ', this.codesRecord);
    }

    customFilter(){
        let newata = this.codesRecordClone.filter(item => {
                let checkCategory = this.selectedValue == 'All' ? true : (item.Category_Main_Primary__c).toUpperCase() == (this.selectedValue).toUpperCase() ? true : false;
                let checkSearch = this.searchValue != '' ? item.Description__c.includes(this.searchValue) || item.Label__c.includes(this.searchValue) ? true : false : true;
                return checkCategory && checkSearch;
            });
            
        return newata;
    }

    handleChange(event) {

        this.selectedValue = event.detail.value;
        this.codesRecord = this.customFilter();
        console.log('this.codesRecord ==> ', this.codesRecord);

        // Additional logic based on selection…

    }

    handleCopy(event) {

        console.log('Inside Handle Copy',  event.target.value);

        if ( navigator.clipboard && window.isSecureContext) {

            this.iconName = 'utility:check';
            this.altText = 'Text Copied';
            navigator.clipboard.writeText(event.target.value)
                .then(() => {
                    // Value successfully copied, now set a timeout to revert the icon and altText
                    setTimeout(() => {
                        this.iconName = 'utility:copy';
                        this.altText = 'Copy Text';
                    }, 2000); // 2000 milliseconds = 2 seconds, you can adjust this time as needed
                })
                .catch(err => {
                    console.error('Error copying text: ', err);
                });

        }

    }


    getPicklistValues() {

        try {
            getPicklistLabelName({
                picklistFieldAPIName: 'Category_Main_Primary__c',
            })
                .then(result => {
                    // set @track contacts variable with return contact list from server 
                    console.log('result of picklisvalue---', result);
                    const optionsList = Object.entries(result).map(([key, value]) => {
                        return { label: value, value: key.replace(/\s+/g, '_').toLowerCase() };
                    });

                    optionsList.unshift({ label: 'All', value: 'All' });

                    console.log('optionsList----->', optionsList);

                    this.optionsList = optionsList;

                    console.log('this.optionsList------>', this.optionsList);

                })
                .catch(error => {
                    console.log('error---->', error);
                    this.showToastMessage("error", "error", "Something went Wrong");
                });
        } catch (error) {
            this.showToastMessage("error", "error", "Something went Wrong");
        }

    }

    handleRowClick(event) {
        this.codeShareCodeId = event.currentTarget.dataset.key;
        console.log("Clicked this.codeShareCodeId:", this.codeShareCodeId);
        // Now you have the key value, you can use it as needed
        this.codeLabel = event.currentTarget.dataset.label;
        console.log('this.codeLabel---->', this.codeLabel);
        this.description = event.currentTarget.dataset.description;
        console.log('this.description--->', this.description);

        this.getSinglerRepoData();
        this.handleNext();
    }

    getSinglerRepoData(){
        try {


            getCodeFileds({
                codeShareCodeId: this.codeShareCodeId,
            })
                .then(result => {
                    // set @track contacts variable with return contact list from server 
                    console.log('result of getCodeFileds---', result);
                    this.codeFileData = result;

                    console.log('this.codeFileData--->', this.codeFileData);

                    for (let index = 0; index < result.length; index++) {
                        const element = result[index];
                        element.versionDataUrl = readBase64EncodedFile(element.versionDataUrl);   
                        const extensions = { 'html': 'doctype:html', 'css': 'custom:custom57', 'js': 'standard:javascript_button', 'page': 'doctype:pages', 'svg': 'doctype:gpres', 'cmp': 'doctype:quip_doc', 'app': 'standard:app', 'auradoc': 'standard:apps_admin', 'cls': 'standard:apex', 'trigger': 'standard:metrics', 'xml': 'doctype:xml' };

                        console.log('extensions[element.fileExtension]--->', extensions[element.fileExtension]);
                        element.iconName = extensions[element.fileExtension] || 'doctype:unknown';

                        result[index] = element; 
                    }

                    console.log('result', result);
                    console.log('result', result[0].versionDataUrl);

                    this.codeFileData = result;            

                })
                .catch(error => {
                    console.log('error---->', error);
                    this.showToastMessage("error", "error", "Something went Wrong");
                });
        } catch (error) {
            console.log('error---->', error);
            this.showToastMessage("error", "error", "Something went Wrong");
        }
    }


    showToastMessage(title, variant, message) {
        try {
            const event = new ShowToastEvent({
                title: title,
                variant: variant,
                message: message,
            });
            this.dispatchEvent(event);
        } catch (error) {
            this.dispatchEvent(new ShowToastEvent({
                title: "error",
                message: "toast error message",
                variant: "error"
            }));
        }
    }

}

function readBase64EncodedFile(encodedData) {
    // Decode the base64 encoded content
    var decodedData = atob(encodedData);
    return decodedData;
}