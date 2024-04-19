import { LightningElement , api, track  } from 'lwc';
import LightningModal from 'lightning/modal';
import UpdateTimesheet  from '@salesforce/apex/TimesheetControllerV2.UpdateTimesheet';
import ExternalCSS from '@salesforce/resourceUrl/ExternalCSS';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';


export default class mtp_rejectTimesheetModelPopUp extends LightningModal {

    @api selectedRecordId;
    @track rejectReason;
    
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

    handleRejectTimesheet(event){
        try{

            event.preventDefault();
            this.rejectReason = this.template.querySelector('[data-value="RejectReason"]').value;
            UpdateTimesheet({recordId : this.selectedRecordId , rejectReason : this.rejectReason  ,comment : this.comment })
            .then(result => {
                this.close();       
            }).catch(error => {
                this.error = error;
            });
        }
        catch(error){
            console.log('Error in handleRejectTimesheet method ==>', {error});
        }
    }


    handleCancel() {
        this.close();
    }

}