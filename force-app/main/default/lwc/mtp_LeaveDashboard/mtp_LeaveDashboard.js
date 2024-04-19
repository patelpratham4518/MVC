import { LightningElement,wire,track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id';
import getUserType from '@salesforce/apex/LeaveDashboardClass.getUserType';
import leaveData from '@salesforce/apex/LeaveDashboardClass.leaveData'
import updateSatus from '@salesforce/apex/LeaveDashboardClass.updateSatus'
import allLeavesListForMentor from '@salesforce/apex/LeaveDashboardClass.allLeavesListForMentor'
import getTrainneList from '@salesforce/apex/LeaveDashboardClass.getTrainneList';
import displayTrainee from '@salesforce/apex/LeaveDashboardClass.displayTrainee';
// import ApproveMail from '@salesforce/apex/LeaveDashboardClass.ApproveMail'

export default class Mtp_LeaveDashboard extends LightningElement {
    
    userid = USER_ID;
    @track contactType;
    @track isSpinner = false;
    @track Leaves = [];
    @track noData = false;
    @track error;
    @track mentor = false;
    @track traineeList =[];
    @track selectedTrainee;
    @track SelectedMonth = '0';
    @track SelectedYearValue = '0000';
    @track years = [];  
    @track Months = [
            { label: 'All Month', value: '0'},
            { label: 'Jan', value: '1'},
            { label: 'Feb', value: '2'},
            { label: 'Mar', value: '3'},
            { label: 'Apr', value: '4'},
            { label: 'May', value: '5'},
            { label: 'Jun', value: '6'},
            { label: 'Jul', value: '7'},
            { label: 'Aug', value: '8'},
            { label: 'Sep', value: '9'},
            { label: 'Oct', value: '10'},
            { label: 'Nov', value: '11'},
            { label: 'Dec', value: '12'},
        ];
    
    @wire(leaveData)
    wireAllAccs({
        error,
        data
    }) {
        console.log({data});
        if (data) {
            this.Leaves = data;
        } else {
            this.error = error;
        }
    }

    connectedCallback(){
        try{
            // this.isSpinner = true;
            // setTimeout(() => {
            //     this.isSpinner = false;
            // }, 1000);
            getUserType({userid : this.userid})
            .then(result => {
                console.log('User Type -> ',result);
                this.contactType = result;
                if(this.contactType == 'Senior Developer'){
                    this.mentor = true;
                }
            }).catch(error => {
                this.error = error;
                console.log('error',error);
            });
            this.SetYEarPicklistValues();
            this.getTrainneData();
        }
        catch(error){
            console.log('Error in Method-->',{error});
        } 
    }

    SetYEarPicklistValues(){
        try{
            var YearPickList = [];
            YearPickList.push({
                label : 'All Years', value : '0000'
            });
            for (var i = 2023; i <= 2050; i++){
                YearPickList.push({label: i.toString(), value: i.toString()});
            } 
            console.log('==> years : ', YearPickList);
            this.years = YearPickList;
        }
        catch(error){
            console.log('Error in Method-->',{error});
        }      
    }

    changeStatus(event){
        try {
            console.log('changeStatus');   
            let sheetStatus = event.currentTarget.value;
            var recordId = event.currentTarget.dataset.val;
            console.log('sheetStatus-->'+sheetStatus);
            console.log('recordId-->',recordId);

            const tdElement = event.target.closest('.slds-hint-parent');
            if(sheetStatus == 'Approved'){
                tdElement.style.color = 'rgb(69, 198, 90)'; 
            } else if(sheetStatus == 'Rejected'){
                tdElement.style.color = 'rgb(246, 81, 81)';
            }

            updateSatus({recId: recordId, status: sheetStatus})
            .then((result) => {
                if(sheetStatus == 'Approved'){
                    this.ShowToast('Leave Approved Successfully', result, 'success');
                }else{
                    this.ShowToast('Leave Rejected Successfully', result, 'success');
                }
                this.getLeavesListForAll(); 
                // console.log('SUCCESS');
                // console.log('result-->',{result});
                // this.Leaves = result
                // return refreshApex(this.Leaves);
            })
            .catch((error) => {
                this.errorMessage=error;
                console.log('unable to update the record due to'+JSON.stringify(this.errorMessage));
            });   
        } catch (error) {
            console.log({error});
        }
    }

    HandleMonthchange(event){
        try{
            console.log('Month--');
            // this.isSpinner = true;
            // setTimeout(() => {
            //     this.isSpinner = false;        
            // }, 500);
            console.log('event.target.value',event.target.value);
            this.SelectedMonth = event.target.value;
            this.getLeavesListForAll();  
        }
        catch(error){
            console.log('Error in Method-->',{error});
        }
    }

    HandleYearChange(event){
        try{
            // this.isSpinner = true;
            //     setTimeout(() => {
            //         this.isSpinner = false;        
            //     }, 500);
            this.SelectedYearValue = event.target.value;
            this.getLeavesListForAll();
        }
        catch(error){
            console.log('Error in Method-->',{error});
        }
    }

    handleTraineeChange(event){
        try{
            this.selectedTrainee = event.target.value;
            console.log('this.selectedTrainee00>',this.selectedTrainee);
            this.getLeavesListForAll();
            // displayTrainee({trn:selectedTrainee})
            // .then((result)=>{
            //     console.log('success');
            // })
            // console.log('==');
        } catch(error){
            console.log('error in handleTraineeChange method : ' + error);
        }
    }

    getLeavesListForAll(){
        try{
            console.log(this.selectedTrainee);
            allLeavesListForMentor({LeavesStatus : 'Pending for Approval', 
                                    Months : this.SelectedMonth, 
                                    years : this.SelectedYearValue, 
                                    Trainee : this.selectedTrainee })
            .then(result => {
                console.log('result is --> ', result);
                this.Leaves = result;
                if(result.length == 0){
                    this.noData = true;
                } else{
                    this.noData = false;
                }
            })
            .catch(err =>{
                console.log('Error is ', err);
            })
        }
        catch(error){
            console.log('Error in Method-->',{error});
        }
    }

    getTrainneData(){
        getTrainneList()
        .then(result => {
            console.log('result --> ',result);
            console.log('OUTPUT : ',result.length);
            result.forEach(currentItem => {
                console.log('currentItem -->> '+currentItem);
            });
            this.traineeList =result.map((item) => Object.assign({}, item, { label: item.Name, value: item.Id }));
            console.log('this.traineeList--->',this.traineeList);
            this.traineeList.unshift({ label: 'All Trainees', value: 'All' });
            if(this.traineeList.length > 0){
                this.selectedTrainee = this.traineeList[0].value;
            }
        }).catch(error => {
            this.error = error;
            console.log('error',error);
        });
    }

    ShowToast(title, message, variant) {
        try{
            const evt = new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            });
            this.dispatchEvent(evt);
        }
        catch(error){
            console.log('Error in ShowToastEvent-->',{error});
        }
    }

}