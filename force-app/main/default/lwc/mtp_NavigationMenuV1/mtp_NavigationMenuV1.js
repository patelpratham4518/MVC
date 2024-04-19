import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import mvlogo from '@salesforce/resourceUrl/mtp_MVLogo';

export default class Mtp_NavigationMenuV1 extends NavigationMixin(LightningElement) {

    @track headerLogo = mvlogo;

    connectedCallback() {

    }

    menuHover() {
        try {
            console.log('menuHover ==>');
            var navEle = this.template.querySelector('.nav-main');
            navEle.classList.add('nav-main-hover');
        } catch (error) {
            console.log('Error in menuHover method ==>', {error});
        }
    }

    handleClick(event) {
        try {
            var pageName = event.target.dataset.name;
            var pageApiName = '';
            console.log('page name ==>'+ pageName);

            if (pageName == 'Home-page') {
                pageApiName = 'Home';
            } else if (pageName == 'Timesheet-page') {
                pageApiName = 'Timesheet__c';
                // pageApiName = 'TimeSheetClone__c';
            } else if (pageName == 'Leave-page') {
                pageApiName = 'Leave__c';
            } else if (pageName == 'profile-page') {
                pageApiName = 'profile__c';
            } else if (pageName == 'Logout-page') {
                this[NavigationMixin.Navigate]({
                    type: 'comm__loginPage',
                    attributes: {
                        actionName: 'logout'
                    },
                });
            } else if(pageName == 'mv-logo') {
                window.open("https://mvclouds.com/", "_blank");
            } else if(pageName == 'back-button') {
                history.back()
            }
            if (pageApiName !='') {
                this.handleNavigation(pageApiName);            
            }
            var navEle = this.template.querySelector('.nav-main');
            navEle.classList.remove('nav-main-hover');
        } catch (error) {
            console.log('Error in handleClick method ==>', {error});
        }
    }

    handleNavigation(pageApiName) {
        try {
            console.log('pageApiName ==>', pageApiName);
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: pageApiName
                },
            });
        } catch (error) {
            console.log('Error in handleNavigation method ==>', {error});
        }
    }

}