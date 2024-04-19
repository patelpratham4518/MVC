import { LightningElement , api, track  } from 'lwc';
import LightningModal from 'lightning/modal';
import UpdateTimesheet  from '@salesforce/apex/TimesheetControllerV2.UpdateTimesheet';
import ExternalCSS from '@salesforce/resourceUrl/ExternalCSS';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

export default class mtp_updateTimesheetPopUp extends LightningModal {

    @api label;
    @api selectedRecordId;
    @api fieldName;
    @api description;
    @track comment;

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