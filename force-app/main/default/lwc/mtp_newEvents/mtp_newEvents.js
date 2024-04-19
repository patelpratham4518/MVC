import { LightningElement, track } from 'lwc';
import eventPage from '@salesforce/resourceUrl/eventPage';
import course from '@salesforce/resourceUrl/course';
import getEvents from '@salesforce/apex/CourseController.getEvents';




export default class Mtp_newEvents extends LightningElement {
    courseimg = course;
    @track eventList = [];
    @track isSpinner = true;


    get imgEvent() {

        return `background-image:url(${eventPage})`;
    }

    connectedCallback() {
        try {
            this.isSpinner = true;

            getEvents()
                .then(result => {
                    console.log({ result });
                    this.eventList = result;
                    this.isSpinner = false;

                })
                .catch(error => {
                    console.log({ error });
                    this.isSpinner = false;

                })


        } catch (e) {
            console.log({ e });
            this.isSpinner = false;

        }


    }

}