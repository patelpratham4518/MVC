import { LightningElement, track, api } from 'lwc';
import success from '@salesforce/resourceUrl/success';
import error from '@salesforce/resourceUrl/error';
import celebrate from '@salesforce/resourceUrl/celebrate';
import toastSucess from '@salesforce/resourceUrl/successToast';


export default class Mtp_ToastMessage extends LightningElement {

    @track success = false;
    @track error = false;
    @track successToast = false;
    successimg = success;
    errorimg = error;
    sucessToastImg = toastSucess;
    message;
    autoCloseTime;

    @api
    showToast(type, message, time) {

        if (type == 'error') {
            this.error = true;
            this.message = message;
            this.autoCloseTime = time;
            setTimeout(() => {
                this.closeModel();
            }, this.autoCloseTime);
        } else if(type == 'success'){
            // this.success = true;
            this.successToast = true;
            this.successMessage = message;
            this.autoCloseTime = time;
            setTimeout(() => {
                this.closeModel();
            }, this.autoCloseTime);
        } else{
            this.success = true;
        }

    }

    get celebrategif() {
        return `background-image:url(${celebrate})`;
    }

    closeModel() {
        this.success = false;
        this.error = false;
        this.type = '';
        this.message = '';
        this.successToast = false;
    }

}