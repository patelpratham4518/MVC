import { LightningElement } from 'lwc';
import ErrorImage from '@salesforce/resourceUrl/ErrorImage';
import ArrowLeft from '@salesforce/resourceUrl/ArrowLogo';
import { NavigationMixin } from 'lightning/navigation';

export default class Mtp_Error_Page extends NavigationMixin(LightningElement) {
    arrowLeft = ArrowLeft;
    get backgroundImage() {
        return `background-position: center;
        background-repeat: no-repeat;
        background-size: cover;
        height:100%; 
        background-image:url(${ErrorImage})`;
    }
    navigateToHome() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            },
        });

    }
}