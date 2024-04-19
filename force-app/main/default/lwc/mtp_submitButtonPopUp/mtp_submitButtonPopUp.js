import { LightningElement , api, track  } from 'lwc';
import LightningModal from 'lightning/modal';
import submittimesheet from '@salesforce/apex/TimesheetControllerV2.submittimesheet';
import MentorSubmitTimeSheet from '@salesforce/apex/TimesheetControllerV2.MentorSubmitTimeSheet';
import approveAllTimesheet from '@salesforce/apex/TimesheetControllerV2.approveAllTimesheet';
import ExternalCSS from '@salesforce/resourceUrl/ExternalCSS';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';


export default class mtp_submitButtonPopUp extends LightningModal {

    @api contactType;
    @api selectedId;
    @api label;
    @api content;
    @api selectedDate;
    @track OnClick = false;
    handleYes() {
        try{
            console.log('this.label',this.selectedId);
            if(this.label =='Approve All'){
                approveAllTimesheet(
                    {
                        timesheetid : this.selectedId,
                    })
                .then(result => {
                }).catch(error => {
                    this.error = error;
                    console.log('error',error);
                })
                this.close();
            }
            else if(this.label == 'Submit'){
                console.log('this.contactType',this.contactType);
                if(this.contactType == 'Senior Developer'){
                    MentorSubmitTimeSheet({userId : this.selectedId, selecteddate : this.selectedDate})
                    .then(result => {
                        console.log('result',result);
                        this.OnClick = true;
                    }
                    ).catch(error => {
                        this.error = error;
                    });
                    this.close();
                }
                else{
                    console.log('this.selectedDate ==> '+this.selectedDate);
                    submittimesheet({userId : this.selectedId, selecteddate : this.selectedDate})
                    .then(result => {
                        this.OnClick = true;
                    }
                    ).catch(error => {
                        this.error = error;
                    });
                    this.close();
                }
            }
            this.close();
        }
        catch(error){
            console.log('Error in handleYes method ==>', {error});
        }

    }   
    handleCancel() {
        this.close();
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
}