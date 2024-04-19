import { LightningElement ,track ,wire } from 'lwc';
import getuserdata from '@salesforce/apex/DharmikDashboardController.getuserdata';
import  getTimeSheetData from '@salesforce/apex/DharmikDashboardController.getTimeSheetData';

export default class NewDharmikDashboard extends LightningElement {

    @track values = 500;
    @track contacts = [];
    @track users = this.contacts;
    @track selectedUserId;
    @track currentWeeklyHours;
    @track timesheet = [];
    @track username;
    @track norecordsfound = true;
    @track selectedUsersIds = [];
    @track StatusValue = 'All';

    @wire(getuserdata)
    getuserdata({error,data}){
        if(data){
            console.log({data});
            this.contacts = data;
            this.users = data;
            this.selectedUserId = data[0].Id;
            this.username = data[0].username;
            console.log(this.selectedUserId);

            this.getTimeSheetData(); 
        }
        else if(error){
            console.log(error);
        }
    }

    handleSectionChange(event) {
        console.log('handleSectionChange');
    }

    handleUserSearch(event) {
        var searchKey = event.target.value;
        if (searchKey.length > 0) {
            this.users = this.contacts.filter(contact => contact.username.toLowerCase().includes(searchKey.toLowerCase()));
        }
        else {
            this.users = this.contacts;
        }
    }

    handleUserSelect(event){
        console.log('handleUserSelect');
        console.log(event.target.id);
        this.selectedUserId = event.target.id;
        var splitId = this.selectedUserId.split('-');
        this.selectedUserId = splitId[0];
        this.username = this.users.filter(contact => contact.Id == this.selectedUserId)[0].username;
        this.getTimeSheetData();
    }

    getTimeSheetData(){
        console.log('getTimeSheetData');
        getTimeSheetData({selectedUserId:this.selectedUserId , statusValue : this.StatusValue})
        .then(result => {
            console.log('result',result);
            this.norecordsfound = result.length == 0 ? true : false;
            this.timesheet = result;
        })
        .catch(error => {
            console.log('error in getTimeSheetDate ----=> ',error);
        });
    }
    handleStatuschange(event){
        console.log('handleStatuschange');
        console.log(event.currentTarget.dataset.id);
    }

    handleCheckboxChange(event){
        console.log('handleCheckboxChange');
        console.log('selectedResourceID ---==>' + event.currentTarget.id);
        console.log(event.target.checked);
        // console.log('selectedResourceID ===> ' + selectedUsersIds); 
        if(event.target.checked){
            console.log(selectedUsersIds); 
            selectedUsersIds.push(event.target.id);
        }
        else{
            selectedUsersIds = selectedUsersIds.filter(id => id != event.target.id);
        }
        console.log(selectedUsersIds);
    }
}