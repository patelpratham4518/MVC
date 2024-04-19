import { LightningElement , api, track, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFieldSet from '@salesforce/apex/TimesheetControllerV2.getFieldSet';
import ExternalCSS from '@salesforce/resourceUrl/ExternalCSS';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';


export default class mtp_previewRecordPopUp extends LightningModal {

    @api selectedRecordId;
    objectName = 'Timesheet_Detail__c';
    fieldSetName = 'PreviewTimeSheet';
    @track isSpinner = true;
    @track fields = [];
    connectedCallback() {
        this.isSpinner = true;
        getFieldSet({objectName: this.objectName, fieldSetName: this.fieldSetName})
        .then(result => {
            this.fields = JSON.parse(result);
            setTimeout(() => {
                this.isSpinner = false;
            }, 1000);
        })
        .catch(error => {
            this.isSpinner = false;
            console.log({error});
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading form',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        });    
    }

    renderedCallback() {
        Promise.all([
            loadStyle(this, ExternalCSS),
        ])
            .then(() => {
            })
            .catch((error) => {
                console.log({ error });
            });
    }
    handleClose() {
        this.close();
    }
   
}