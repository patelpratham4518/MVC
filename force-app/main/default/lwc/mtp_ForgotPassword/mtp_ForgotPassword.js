import { LightningElement, track } from 'lwc';
import mtb_Login_Images from '@salesforce/resourceUrl/mtb_Login_Images';
import forgotpassword from '@salesforce/apex/mtp_SigninController.forgotSitePassword';

export default class Mtp_ForgotPassword extends LightningElement {

    hootie = mtb_Login_Images + '/hootie.png';
    lamp_Img = mtb_Login_Images + '/lamp_Img.png';
    highResLogo = mtb_Login_Images + '/MV_Cloud_HighResLogo.png';
    username = '';

    @track isSpinner = false;

    connectedCallback(){

    }

    renderedCallback(){

    }

    // Get Background Image
    get backgroundImage() {
        return `background-image:url(${mtb_Login_Images + '/forgotpassword.png'})`;
    }

    handlechange(event){
        this.username = event.target.value;
    }

    resetPass(){

        console.log('this.username-->',this.username);
        if(this.username == null || this.username == '' || this.username == undefined){
            this.template.querySelector('c-mtp_-toast-message').showToast('error', 'Please Enter Username First!', 3000);
        }
        else{

            forgotpassword({
                    usernameval: this.username
                })
                .then((result) => {
                    console.log({ result });
                    if (result == 'true') {
                        window.location.replace('/s/');
                    } else {
                        console.log('else');
                        this.errormsg = result;
                    }
                    this.template.querySelector('c-mtp_-toast-message').showToast('success', 'Reset Password link was send to your Email!', 3000);
                })
                .catch((error) => {
                    console.log(error);
                    this.template.querySelector('c-mtp_-toast-message').showToast('success', error, 3000);
                });
        }
    }
}