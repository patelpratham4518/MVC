import { LightningElement,track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getUserType from '@salesforce/apex/ProfileCopmController.getUserType';

export default class Mtp_ProfileComp extends NavigationMixin(LightningElement) {
    connectedCallback(){
        try{
            console.log('Profile Page');
            // console.log('this.userid',this.userid);
            getUserType()
            .then(result => {
                console.log('result',result);
                this.UserType = result;
                if(this.UserType == 'Current User is System Administrator'){
                    console.log('result : ',this.UserType);
                }
                else{
                    this[NavigationMixin.Navigate]({
                        type: 'comm__namedPage',
                        attributes: {
                            name: 'Error',
                            url: '/s//error'
                        },
                    });
                }
            }).catch(error => {
                console.log('Error : ',error);
            });
        }
        catch(error){
            console.log('Error in MethodName-->',{error});
        }
    }
    // handleNavigation() {
    //     try {
    //         var pageApiName = 'MentorTimeSheet__c';
    //         this[NavigationMixin.Navigate]({
    //                 type: 'comm__namedPage',
    //                 attributes: {
    //                 name: pageApiName,
    //             },
    //         });
    //     } catch (error) {
    //         this.isSpinner = false;
    //         console.log('Error in handleNavigation method ==>', {error});
    //     }
    // }

    
}