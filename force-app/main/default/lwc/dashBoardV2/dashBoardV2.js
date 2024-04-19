import { LightningElement, track } from 'lwc';
import getUsersList from '@salesforce/apex/DashBoardV2.getUsersList';



export default class DashBoardV2 extends LightningElement {

    @track selectedStatus = 'Not Submitted'; 
    @track selectedMonth = (new Date().getMonth() + 1).toString();
    @track selectedYear = new Date().getFullYear().toString();

    @track timesheetData = [];
    @track timesheetDataList = false;
    

    @track StatusOptions = [
        {label: 'Not Submitted', value: 'Not Submitted'},
        {label: 'Not filled', value: 'Not filled'},
        {label: 'Not approved', value: 'Not approved'},
    ]

    @track months =  [
        { label: 'January', value: '1' },
        { label: 'February', value: '2' },
        { label: 'March', value: '3' },
        { label: 'April', value: '4' },
        { label: 'May', value: '5' },
        { label: 'June', value: '6' },
        { label: 'July', value: '7' },
        { label: 'August', value: '8' },
        { label: 'September', value: '9' },
        { label: 'October', value: '10' },
        { label: 'November', value: '11' },
        { label: 'December', value: '12' }
    ];

    @track years = [
        { label: '2022', value: '2022' },
        { label: '2023', value: '2023' },
        { label: '2024', value: '2024' },
        { label: '2025', value: '2025' },
        { label: '2026', value: '2026' },
        { label: '2027', value: '2027' },
        { label: '2028', value: '2028' },
        { label: '2029', value: '2029' },
        { label: '2030', value: '2030' }
    ];

    connectedCallback() {
        this.getListOfusers();
    }



    handleChange(event) {
        if (event.target.label === 'Years') {
            this.selectedYear = event.target.value;
        }
        if (event.target.label === 'Months') {
            this.selectedMonth = event.target.value;
        }
        if (event.target.label === 'Status') {
            this.selectedStatus = event.target.value;
        }
        this.getListOfusers();
        console.log('SelectedOption', event.target.value);
    }

    getListOfusers() {
        getUsersList({selectedStatus: this.selectedStatus, selectedMonth: this.selectedMonth, selectedYear: this.selectedYear})
        .then(result => {
            if(result.length>0){
                this.timesheetDataList = true;
                this.timesheetData = result;
            } else{
                this.timesheetDataList = false;            
            }
        })
        .catch(error => {
            console.log('error in getListOfusers ----> ', error);
        });
    }
}