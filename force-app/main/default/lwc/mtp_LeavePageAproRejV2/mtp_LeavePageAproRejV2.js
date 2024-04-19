import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';


import mtp_LeavePageBG from '@salesforce/resourceUrl/mtp_LeavePageBG';
import course from '@salesforce/resourceUrl/course';
import timesheet from '@salesforce/resourceUrl/timesheet';
import leave from '@salesforce/resourceUrl/leave';
import calender from '@salesforce/resourceUrl/calender';
import arrow from '@salesforce/resourceUrl/arrow';
import USER_ID from '@salesforce/user/Id';
import middleflight from '@salesforce/resourceUrl/mtp_leaveflighticon';
import { getRecord } from 'lightning/uiRecordApi';


// import Start_Date from '@salesforce/schema/Leave__c.Start_Date__c';

import getUserType from '@salesforce/apex/LeaveControllerV2.getUserType';
// import getFieldSet from '@salesforce/apex/LeaveControllerV2.getFieldSet';
// import saveLeaves from '@salesforce/apex/LeaveControllerV2.saveLeaves';
// import GetMentorName from '@salesforce/apex/LeaveControllerV2.GetMentorName';
// import allLeavesList from '@salesforce/apex/LeaveControllerV2.allLeavesList';
import allLeavesListForMentor from '@salesforce/apex/LeaveControllerV2.allLeavesListForMentor';
import StatusUpdateMethod from '@salesforce/apex/LeaveControllerV2.StatusUpdateMethod';
import getTrainneList from '@salesforce/apex/LeaveControllerV2.getTrainneList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Mtp_LeavePage extends NavigationMixin(LightningElement) {

    @api recordId;
    @track username;

    imgarrow = arrow;
    courseimg = course;
    timesheetimg = timesheet;
    leaveimg = leave;
    calenderimg = calender;
    flighticon = middleflight;

   @track userType;                         // Store the type of User (Mentor Or Trainee)
    isSpinner = false;        

    ShowMentorName = false;                 //To Show Mentor Name 
    ShowApplyForLeave = false;              // To Display Aplly for Leave Button In case on Trainee
    ShowLeaveList = true;                  // To Show-Hide Leave List 
    ShowLeaveListInt = 0;                   // Use With Leavelist Variable For Logical Purpose
    ShowIllustration = false;                // To Show-Hide Aniamtion/Illutration
    ShowApproveRejectOption =false;         // TO Show-Hide Approve Reject Button in Case Of Mentor
    ShowLeaveDetailPopup = false;           // to Show-Hide Leave Detail Popup (ModalBox)

    @track mentor = false;                  // To check if Logged in USer is Mentor or not
    @track trainee;

    lvt_type_color;                         // To change the Class Name For Leave Status Label (Geern--> Approve. red-->Rejected oranhe-->Pending)
    LeaveStatus;                            //  TO Change Leave list Header Dynamically

    objectName = 'Leave__c';
    fieldSetName = 'ApplyForLeaveModalBox';
    @track fields = [];
    @track projects = [];
    @track userId = USER_ID;
    @track traineeList =[];                     // Store All The Trainee Accosiaated With Logged in Mentor(Contact)
    @track selectedTrainee;                     // Store Seleced Trainee Id Based On Combobox And Passing to Apex Class

    @track mentorName;
    @track LeaveUpdateId;                   // Store The LeaveId Which We are Going To Approve or Rejecte (Update) And Passing to Apex Class

    @track TotalLeaves;    

    @track LeaveDetails = [];

    @track SelectedYearValue = '0000';                             // Store Value OF Month on Month Change Event
    @track years = [];                                             //Store Object Of Array For Year Picklist

    @track SelectedMonth = '0';                                  // Store Value OF Month on Month Change Event
    // @track Months = [];
    @track Months = [                                            // Generate And Store Object Of Array For Month Picklist
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
    

    UtilityIcon;                             // To Display And Chnage logo on Popup Box

    Lev_Name;
    Lev_DayType;
    Lev_StartDay;
    Lev_EndDay;
    Lev_Reason;
    Lev_Id;
    Lev_Status;
    Lev_LeaveType;


    get imghome() {
        return `background-image:url(${mtp_LeavePageBG})`;
    }


    connectedCallback(){
        try{
            this.UserTypeChecking();
            this.isSpinner = true;
                setTimeout(() => {
                    this.isSpinner = false;
                }, 1000);
        
        // this.getFieldValueMethod();
        this.getTraineeDetail();
        this.SetYEarPicklistValues();
        }
        catch(error){
            console.log('Error in Method-->',{error});
        }
        
    }



    // =============> Checking User in trainee Or Mentor <====================s

    UserTypeChecking(){
        try{
        getUserType()
        .then(result =>{
            this.userType = result;
            console.log('User type : '+ this.userType);

            if(this.userType == 'Senior Developer'){
                this.mentor = true;
                this.getLeavesListForAll();
            } else if(this.userType == 'Developer'){
                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        name: 'Error',
                        url: '/s//error'
                    },
                });
            }
        })
        .catch(error =>{
            console.log('Error in Method-->',{error});
        })
    }
    catch(error){
        console.log('error => ',error);
    }
    }


         // =============> Function to Get Mentor Name From Apex Class <======= 
    // GetMentorNameMethod(){
    //     try{
    //         GetMentorName()
    //         .then(result =>{
    //             console.log('Result-->',{result});
    //             this.mentorName = result;
    //             console.log('mentor name :' + this.mentorName);
    //         }) 
    //         .catch(error =>{
    //             console.log('error :' , error);
    //         })

    //     }
    //     catch(error){
    //         console.log('Error in Method-->',{error});
    //     }
           
    //     }

// =============> Apex Menthod That Returnig All Trainee Id Associed With Mentro And Store That In Variable <======= 
        getTraineeDetail(){
            try{
            // this.isSpinner = true;
            getTrainneList()
            .then(result => {
                this.traineeList = result.map((item) => Object.assign({}, item, { label: item.Name, value: item.Id }));
                if(this.traineeList.length > 0){
                    this.selectedTrainee = this.traineeList[0].value;
                    this.getLeavesListForAll();
                    // this.handleDateChange();
                    // this.handleTraineeChange();
                    this.isSpinner = false;
                }
            }).catch(error => {
                this.error = error;
                this.isSpinner = false;
            });
        }
        catch(error){
            console.log('Error in Method-->',{error});
        }

        }


// =============> Store Trainee Id When Mentor Select Trainne Form ComboBox <======= 
        handleTraineeChange(event){
            try{
            this.isSpinner = true;
                setTimeout(() => {
                    this.isSpinner = false;        
                }, 500);
            if(this.selectedTrainee == undefined){
                this.selectedTrainee = this.traineeList[0].value;
                this.getLeavesListForAll();
            }
            else{
                console.log('event.target.value',event.target.value);
                this.selectedTrainee = event.target.value;
                this.getLeavesListForAll();
                
            }
            // this.getTimesheetData();
            // this.isSpinner = false;
        }
        catch(error){
            console.log('Error in Method-->',{error});
        }
        }

       //==============> Function To Get Leave List On Month Change<============================== 
        HandleMonthchange(event){
            try{
            this.isSpinner = true;
                setTimeout(() => {
                    this.isSpinner = false;        
                }, 500);
                console.log('event.target.value',event.target.value);
                this.SelectedMonth = event.target.value;
                this.getLeavesListForAll(); 
            
        }
        catch(error){
            console.log('Error in Method-->',{error});
        }
        }


        //==============> Loop To Create Year PIckist Value<==============================
        SetYEarPicklistValues(){
            try{

        var YearPickList = [];
        YearPickList.push({
            label : 'All Years', value : '0000'
        });
        for ( var i=2023; i<= 2050; i++){
            YearPickList.push({
                label: i.toString(), value: i.toString()
            });
        } 
        console.log('==> years : ', YearPickList);
        this.years = YearPickList;
    }
    catch(error){
        console.log('Error in Method-->',{error});
    }
            
    }

       //==============> Function To Get Leave List On Year Change<============================== 
        HandleYearChange(event){
            try{
            this.isSpinner = true;
                setTimeout(() => {
                    this.isSpinner = false;        
                }, 500);
            this.SelectedYearValue = event.target.value;
            console.log(event.target.value);
            // this.getLeavesListForAll();
            // this.getLeavesListForAll();
            if(this.userType == 'Senior Developer'){
                this.getLeavesListForAll(); 
            }
            else if(this.userType == 'Developer'){
                this.getLeavesListForAll();
            }
        }
        catch(error){
            console.log('Error in Method-->',{error});
        }
        }


// ========================> To display Leave List <=================================================      

        getLeaveList(event){
        try{
            console.log('user type = '+ this.userType );
            if(this.userType == 'Senior Developer'){
                let dataname = event.currentTarget.dataset.name;
                console.log(dataname);
                this.getLeavesListForAll(dataname); 
            }
            else if(this.userType == 'Developer'){
                let dataname = event.currentTarget.dataset.name;
                console.log(dataname);
                this.getLeavesListForAll(dataname);
            }
        }
        catch(error){
            console.log('Error in Method-->',{error});
        }

        }


    // ----------------------------------------------------------- [ Mentor Side Methods ] ----------------------------------------------------------------------------------------------------------------------------------------


      // =============> Function to Get Leave Detail From Apex Class <======
      getLeavesListForAll(name){
        try{

        if(name == 'PendingLeaves'){
            console.log(name);
            this.UtilityIcon  = 'utility:resource_capacity';           
            this.ShowApproveRejectOption = true;
            console.log('trainee Id' +this.selectedTrainee);

        // =============> Apex Method That returning Peneding Leaves <=======
        allLeavesListForMentor({LeavesStatus : 'Pending for Approval', contactid : this.selectedTrainee, Months : this.SelectedMonth, years : this.SelectedYearValue  })
            .then(result => {
                this.LeaveDetails = result;                         // Add Leaves List in For Each Tempalate
                this.lvt_type_color = 'lv-type';
                console.log('result is  :  ', result);
                this.LeaveStatus = 'Pending for Approval';                // Set dynamic header
                this.TotalLeaves = result.length;  

                if(result.length == 0){                               // hide Show Illustration
                    this.ShowIllustration = true;
                    console.log('result empty');
                } else{
                    this.ShowIllustration = false;
                }
                this.isSpinner = false;
            })
            .catch(err =>{
                console.log('Eroor is ', err);
                this.isSpinner = false;
            })
            // -----------------------------------------------
           
        } 
        
        else if(name == 'ApprovedLeaves'){
         
            console.log(name);
            this.UtilityIcon  = 'utility:smiley_and_people';
            this.ShowApproveRejectOption = false;

        // =============> Apex Method That returning Approved Leaves <========
        allLeavesListForMentor({LeavesStatus : "Approved", contactid : this.selectedTrainee, Months : this.SelectedMonth, years : this.SelectedYearValue })
            .then(result => {
                this.LeaveDetails = result;
                this.lvt_type_color = 'lv-type-Approved';
                console.log('result is  : ', result);
                this.LeaveStatus = 'Approved Leaves';
                this.TotalLeaves = result.length;  

                if(result.length == 0){
                    this.ShowIllustration = true;
                    console.log('result empty');
                } else{
                    this.ShowIllustration = false;
                } 
                this.isSpinner = false;
            }) 
            .catch(err =>{
                console.log('Eroor is ', err);
                this.isSpinner = false;
            })


            
        } else if (name == 'RejectedLeaves'){
           
            console.log(name);
            this.UtilityIcon  = 'utility:sentiment_negative';
            this.ShowApproveRejectOption = false;

        
        // =============> Apex Method That returning Rejected Leaves <=========
        allLeavesListForMentor({LeavesStatus : "Rejected", contactid : this.selectedTrainee, Months : this.SelectedMonth, years : this.SelectedYearValue })
            .then(result => {
                this.LeaveDetails = result;
                this.lvt_type_color = 'lv-type-Rejected';
                console.log('result is : ', result);
                console.log(result.length);
                this.LeaveStatus = 'Rejected Leaves';
                this.TotalLeaves = result.length; 

                if(result.length == 0){
                    this.ShowIllustration = true;
                    console.log('result empty');
                } else{
                    this.ShowIllustration = false;
                }
                this.isSpinner = false;
            })
            .catch(err =>{
                console.log('Eroor is ', err);
                this.isSpinner = false;
            })
        } 
        else{

            console.log(name);
            this.UtilityIcon  = 'utility:resource_capacity';
            this.ShowApproveRejectOption = true;

            console.log('trainee Id' +this.selectedTrainee);
            
            allLeavesListForMentor({LeavesStatus : 'Pending for Approval', contactid : this.selectedTrainee, Months : this.SelectedMonth, years : this.SelectedYearValue })
            .then(result => {
                this.LeaveDetails = result;                         // Add Leaves List in For Each Tempalate
                this.lvt_type_color = 'lv-type';
                console.log('result is  :  ', result);
                this.LeaveStatus = 'Pending for Approval';                // Set dynamic header
                this.TotalLeaves = result.length;

                if(result.length == 0){                               // hide Show Illustration
                    this.ShowIllustration = true;
                    console.log('result empty');
                } else{
                    this.ShowIllustration = false;
                }
                this.isSpinner = false;
            })
            .catch(err =>{
                console.log('Eroor is ', err);
                this.isSpinner = false;
            })

        }

    }
    catch(error){
        console.log('Error in Method-->',{error});
    }
    }


//    ==========================> Function to update Status <===========================================
    UpdateLeaveStatus(event){
        this.LeaveUpdateId = event.currentTarget.dataset.id;
        console.log('leave Id : ', this.LeaveUpdateId);

        var UpdateStatusOption  = event.currentTarget.dataset.name;
        console.log('leave Id : ', UpdateStatusOption);
     try{
            if(UpdateStatusOption == 'ApproveLeaveStatus'){
                StatusUpdateMethod({Status : "Approving", LeaveID : this.LeaveUpdateId})
                .then(result =>{
                    console.log('Leave Approved :)'+ result);
                    if(result == 'Status Update'){
                        this.template.querySelector('c-mtp_-toast-message').showToast('success', 'Leave Approved Successfully', 3000);
                        this.getLeavesListForAll();
                        this.closeLeaveDeatilPopup();
                    }
                    else{
                        this.template.querySelector('c-mtp_-toast-message').showToast('error', 'You Can not Approve Past Leave', 3000);
                    }
                })
                .catch(error =>{
                    console.log('Error : ',error);
                })
            }
            else if(UpdateStatusOption == 'RejectLeaveStatus'){
                StatusUpdateMethod({Status : "Rejected", LeaveID : this.LeaveUpdateId})
                .then(result =>{
                    console.log('Leave Rejected : )'+ result);
                    if(result == 'Status Update'){
                        this.template.querySelector('c-mtp_-toast-message').showToast('success', 'Leave Rejected Successfully', 3000);
                        this.getLeavesListForAll();
                        this.closeLeaveDeatilPopup();
                    }
                    else{
                        this.template.querySelector('c-mtp_-toast-message').showToast('error', 'You Can not Reject Past Leave', 3000);
                    }
                })
                .catch(error =>{
                    console.log('Error : ',error);
                })

            }
            
        }
        catch(error){
            console.log('Error in Method-->',{error});
            this.template.querySelector('c-mtp_-toast-message').showToast('error', 'error', 3000);
        }
    }
    // ================> Function to Get Value From HTML and Show In PopUpBox <============================
    getDataValue(event){
        try{
                this.Lev_Id = event.currentTarget.dataset.levid;
                this.Lev_Name = event.currentTarget.dataset.levname;
                this.Lev_DayType = event.currentTarget.dataset.day;
                this.Lev_StartDay = event.currentTarget.dataset.startdate;
                this.Lev_EndDay = event.currentTarget.dataset.enddate;
                this.Lev_Reason = event.currentTarget.dataset.reason;
                this.Lev_Status = event.currentTarget.dataset.status;
                this.Lev_LeaveType = event.currentTarget.dataset.leavetype; 
                this.ShowLeaveDetailPopup = true;
    }
    catch(error){
        console.log('error => ',error);
    }
    }
    // ================> Function to Close PopUpBox <============================
     closeLeaveDeatilPopup(){
        this.ShowLeaveDetailPopup = false;
    }

    handleNavigateToLeadLeave(){
        try{

            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'Leave__c',
                    url: '/s/leave'
                },
            });
        }
        catch(error){
            console.log('Error in Method-->',{error});
        }
    }



}