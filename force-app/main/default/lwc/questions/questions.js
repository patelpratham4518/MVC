import {LightningElement, track, api} from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import wait from './waitpage.html';
import ques from './questions.html';
import ls from './languageselection.html';
import qp from './questionspage.html';
import tp from './thankyou.html';
import ap from './aptitudepage.html';
import qc from '@salesforce/resourceUrl/questioncss';
import getContact from '@salesforce/apex/QuestionsController.getContact';
import getAptitudeQuestions from '@salesforce/apex/QuestionsController.getAptitudeQuestions';
import getQues from '@salesforce/apex/QuestionsController.getQuestions';
import saveAns from '@salesforce/apex/QuestionsController.saveAnswers';
import saveAptitudeResult from '@salesforce/apex/QuestionsController.saveAptitudeResult';
import getAnswerData from '@salesforce/apex/QuestionsController.getAnswerData';
import updateAnsRec from '@salesforce/apex/QuestionsController.updateAnsRec';
import saveSingleAnswer from '@salesforce/apex/QuestionsController.saveSingleAnswer';


export default class Questions extends LightningElement {
    @track showspinner = false;
    @track displayOptionA = ques;

    // questions Page
    @track contactId = '';
    @track contactData = {};

    // aptitudepage Page
    @track answerObj;
    @track currentAptPage = 1;
    @track aptitudeQuestionWrapper = [];
    @track currentAptitudeQuestion = [];
    @track confirmAptPopup = false;

    // languageselection Page
    @track langdisable = true;
    @track confirmLanPopup = false;
    @track errormsg;
    @track selectedlanguages = [];
    @track showlanguages = '';
    languageList = [
        { label: 'HTML & CSS', value: 'HTML & CSS' },
        { label: 'JavaScript', value: 'JavaScript' },
        { label: 'Python', value: 'Python' },
        { label: 'Java', value: 'Java' }
    ];

    // questionspage Page
    @track confirmQuePopup = false;
    @track questionList = [];
    @track alreadySubmited = false;
    @track successToast = false

    // Timer
    @track timeVal = '';
    @track showInputArea = true;
    @track secondsRemaining = 3600; // time in seconds
    @track intervalHandle;

    // Waiting page
    @track examinfo = '';
    @track examDateTime;
    @track showWaitingPage = true;

    render() {
        return this.displayOptionA;
    }

    connectedCallback() {
        if(localStorage.getItem('countdownTimerTime') != null ){
            this.timeVal = localStorage.getItem('countdownTimerTime');
            this.secondsRemaining = localStorage.getItem('countdownTimerTimeSeconds');
        } 
        let params = (new URL(document.location)).searchParams;
        this.contactId = params.get("conId");
        this.getContactDetails(this.contactId);
        this.tick();
    }

    renderedCallback() {
        Promise.all([
            loadStyle(this, qc)
        ]).then(() => { })
        .catch(error => {   
            console.error('Error => ',error.message);
        });
    }

    // ***************************************
    // ***** questions Page JS Start *****

    getContactDetails(contactId){
        this.showspinner = true;
        getContact({
            contactId : contactId
        })
        .then(result => {
            this.contactData = result;
            console.log('Contact => ',result);
            if (this.contactData.Account.Exam_Date_Time__c) {
                // Convert Exam_Date_Time__c to JavaScript Date object
                this.examDateTime = new Date(this.contactData.Account.Exam_Date_Time__c);
                console.log(this.examDateTime);
                // this.examinfo = this.examDateTime;
                this.examinfo = this.examDateTime.toLocaleString('en-US', {
                    year: 'numeric',
                    month: 'short',
                    day: '2-digit',
                    hour: 'numeric',
                    minute: '2-digit',
                    hour12: true
                });
    
                // Get the current date and time
                const currentDateTime = new Date();
                const StartExamDateTime = new Date(this.examDateTime);
                const EndExamDateTime = new Date(this.examDateTime.setHours(this.examDateTime.getHours() + 2));
                // Compare Exam_Date_Time__c with the current date and time
                console.log("Current time 1 :::  "  + currentDateTime);
                console.log( " last 2 Exam_Date_Time::: " + EndExamDateTime);
                console.log("start Exam date time ::: " + StartExamDateTime);
                if (StartExamDateTime >= currentDateTime || EndExamDateTime< currentDateTime) {
                    this.displayOptionA = wait;
                }
                if (EndExamDateTime< currentDateTime){
                    this.showWaitingPage = false;
                    console.log("show Waiting page ::: " + this.showWaitingPage);
                }
                
            }
            this.showspinner = false;
            if (this.contactData.Exam_Submitted__c == true) {
                this.alreadySubmited = true;
                this.displayOptionA = tp;
            } 
        })
        .catch(error => {
            this.showspinner = false;
            console.error('Error => ',error.message);
            alert('Something went wrong. Contact your interviewer.');
        });
    }

    startExam(){
        if(this.contactId!=null){

            getAnswerData({conId: this.contactId})
            .then(result => {
                this.answerObj = result;
                if (this.answerObj.Aptitude_Marks__c != undefined && this.answerObj.Aptitude_Data__c != undefined) {
                    if (this.answerObj.Language_Type__c == undefined) {
                        this.displayOptionA = ls;
                    } else{
                        this.gotoquestions()
                    }
                } else{
                    this.startCountdown();
                    this.getAptitudeData();
                }
            })
            .catch(error => {
                console.error('Error ==> ',error.message);
                this.showspinner = false;
                alert('Something went wrong. Contact your interviewer.');
            });
        }else{
            alert('Something went wrong. Contact your interviewer.');
        }
    }

    // ***** questions Page JS End *****
    // *************************************


    // **************************************
    // ***** aptitudepage Page JS Start *****

    getAptitudeData(){
        this.showspinner = true;
        getAptitudeQuestions()
        .then(result => {
            if (result.length < 30) {
                console.error('questions is less then 30, Enough question is not availavle');
                alert('Something went wrong. Contact your interviewer.');
            } else {
                let answerObj = this.answerObj;
                let oldAptQuestion = [];
                if (answerObj.Aptitude_Data__c != undefined) {
                    let oldAptData = JSON.parse(answerObj.Aptitude_Data__c);
                    oldAptData.forEach(element => {
                        oldAptQuestion.push(element.Id);
                    });
                }
    
                let shuffledResult = Array.from(result).sort((a, b) => 0.5 - Math.random());
                if (oldAptQuestion.length == 30) {
                    let newshuffledResult = [];
                    shuffledResult.forEach(element => {
                        if (oldAptQuestion.includes(element.Id)) {
                            newshuffledResult.push(element);
                        }
                    });
                    shuffledResult = newshuffledResult;
                }
    
                let aptitudeQuestionWrapper = [];
                for (let i = 0; i < shuffledResult.length; i++) {
                    let que = shuffledResult[i];
                    let optionsList = que.Aptitude_Options__c.split('###');
                    optionsList.forEach(element => {
                        element = element.trim();
                    });
                    let newOptionSet = new Set();
                    newOptionSet.add(que.Aptitude_Answer__c);
                    let totalOption = 4;
                    if (que.Aptitude_Options_Count__c != null && que.Aptitude_Options_Count__c != undefined) {
                        totalOption = que.Aptitude_Options_Count__c
                    }
                    if (optionsList.length > totalOption) {
                        while(newOptionSet.size < totalOption){
                            newOptionSet.add(this.getRandomItem(optionsList));
                        }
                    } else{
                        newOptionSet = new Set(optionsList);
                    }
                    let shuffledOption = Array.from(newOptionSet).sort((a, b) => 0.5 - Math.random());
                    
                    let radioOptions = [];
                    shuffledOption.forEach(element => {
                        radioOptions.push({ label: element, value: element});
                    });
                    
                    let questionObj = {};
                    questionObj.questionNumber = i+1;
                    questionObj.questionId = que.Id;
                    questionObj.questionData = que;
                    questionObj.question = que.Question__c;
                    questionObj.options = shuffledOption;
                    questionObj.radioOptions = radioOptions;
                    questionObj.rightAnswer = que.Aptitude_Answer__c.trim();
                    questionObj.selectedAnswer = '';
                    aptitudeQuestionWrapper.push(questionObj);
                    if (i == 29) {
                        break;
                    }
                }
    
                let currentAptitudeQuestion =  [];
                for (let i = 0; i < 10; i++) {
                    currentAptitudeQuestion.push(aptitudeQuestionWrapper[i]);
                }
    
                this.currentAptitudeQuestion = currentAptitudeQuestion;
                this.aptitudeQuestionWrapper = aptitudeQuestionWrapper;
                this.showspinner = false;
                this.displayOptionA = ap;
                this.updateAptAns();
            }
        })
        .catch(error => {
            console.error('Error ==> ',error.message);
            this.showspinner = false;
            alert('Something went wrong. Contact your interviewer.');
        });
    }

    getRandomItem(arr){
        const randomIndex = Math.floor(Math.random() * arr.length);
        const item = arr[randomIndex];
        return item;
    }

    handleOptionChange(event){
        var selectedQuestionId = event.currentTarget.dataset.id;
        var selectedValue = event.detail.value;

        this.aptitudeQuestionWrapper.forEach(element => {
            if (element.questionId == selectedQuestionId) {
                element.selectedAnswer = selectedValue;
            }
        });
    }

    handlePreviousApt(){
        this.topFunction();
        this.currentAptPage = this.currentAptPage - 1;
        this.paginationAptHelper();
    }

    handleNextApt(){
        this.topFunction();
        this.currentAptPage = this.currentAptPage + 1;
        this.paginationAptHelper();
    }

    topFunction(){
        const scrollOptions = {
            left: 0,
            top: 0,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
    }

    get disablePreviousApt(){
        return this.currentAptPage == 1;
    }

    get disableNextApt(){
        return this.currentAptPage == 3;
    }

    paginationAptHelper(){
        let aptitudeQuestionWrapper = this.aptitudeQuestionWrapper
        let page = this.currentAptPage-1;

        let currentAptitudeQuestion =  [];
        for (let i = page*10; i < page*10+10; i++) {
            currentAptitudeQuestion.push(aptitudeQuestionWrapper[i]);
        }

        this.currentAptitudeQuestion = currentAptitudeQuestion;
    }

    submitAptHandel(){
        this.confirmAptPopup = true;
    }

    closeAptPopup(){
        this.confirmAptPopup = false
    }

    submitAptitude(){
        this.showspinner = true;
        let aptitudeQuestionWrapper = this.aptitudeQuestionWrapper;
        console.log('aptitudeQuestionWrapper ==> ',aptitudeQuestionWrapper);

        let rightCount = 0;
        aptitudeQuestionWrapper.forEach(element => {
            if (element.rightAnswer == element.selectedAnswer) {
                rightCount++
            }
        });
        
        this.updateAptAns();
        
        saveAptitudeResult({
                ansId: this.answerObj.Id,
                aptitudeMarks: rightCount, 
            })
            .then(result => {
                this.showspinner = false;
                this.displayOptionA = ls;
                this.stopCountdown();
            })
            .catch(error => {
                console.error('Error ==> ',error.message);
                this.showspinner = false;
                alert('Something went wrong. Contact your interviewer.');
            });

    }

    updateAptAns(){
        let aptitudeQuestionWrapper = this.aptitudeQuestionWrapper;

        let aptDataList = [];
        aptitudeQuestionWrapper.forEach(element => {
            let aptObj = {
                "Id": element.questionId,
                "question": element.question,
                "rightAnswer": element.rightAnswer,
                "selectedAnswer": element.selectedAnswer
            };
            aptDataList.push(aptObj);
        });
        let aptData = JSON.stringify(aptDataList);

        updateAnsRec({ansId: this.answerObj.Id, aptData: aptData})
    }

    // ***** aptitudepage Page JS End *****
    // **************************************


    // *******************************************
    // ***** languageselection Page JS Start *****

    checkboxchange(event){
        var checkboxlist = this.template.querySelectorAll('input[type="checkbox"]:checked');
        if(checkboxlist.length == 2){
            var unchecked = this.template.querySelectorAll('input[type="checkbox"]:not(:checked)');
            for(var s of unchecked){
                s.disabled = true;
            }
            // this.checkboxdisable ==
        }else if(checkboxlist.length < 2){
            var unchecked = this.template.querySelectorAll('input[type="checkbox"]');
            for(var s of unchecked){
                s.disabled = false;
            }
        }

        if(checkboxlist.length >= 2){
            this.langdisable = false;
        }else{
            this.langdisable = true;
        }
    }

    nextfromlanguage(event){
        var checkboxlist = this.template.querySelectorAll('input[type="checkbox"]:checked');
        if(checkboxlist.length > 1){
            this.selectedlanguages = [];
            this.showlanguages = '';
            for(var s of checkboxlist){
                this.selectedlanguages.push(s.value);
                this.showlanguages += s.name + ', ';
            }
            this.showlanguages = this.showlanguages.slice(0,this.showlanguages.length - 2);
            this.confirmLanPopup = true;
        }else{
            this.errormsg = 'Please Select atleast 2 value!';
        }
    }

    closeLanPopup(){
        this.confirmLanPopup = false;
    }

    // ***** languageselection Page JS End *****
    // *****************************************


    // ***************************************
    // ***** questionspage Page JS Start *****

    gotoquestions() {
        this.showspinner = true;
        getQues({
                langlist: this.selectedlanguages,
                ansId: this.answerObj.Id
            })
            .then(result => {
                this.startCountdown();
                if (result.length == 0) {
                    console.error('Enough question is not availavle');
                    alert('Something went wrong. Contact your interviewer.');
                } else {
                    let answerObj = this.answerObj;
                    let queAnsMap = new Map();

                    queAnsMap.set(answerObj.Question_1__c, answerObj.Answer_1__c);
                    queAnsMap.set(answerObj.Question_2__c, answerObj.Answer_2__c);
                    queAnsMap.set(answerObj.Question_3__c, answerObj.Answer_3__c);
                    queAnsMap.set(answerObj.Question_4__c, answerObj.Answer_4__c);
                    queAnsMap.set(answerObj.Question_5__c, answerObj.Answer_5__c);
                    queAnsMap.set(answerObj.Question_6__c, answerObj.Answer_6__c);

                    let questionList = []
                    result.forEach((element, index) => {
                        let queObj = {
                            "count" : index+1,
                            "Id" : element.Id, 
                            "question" : element.Question__c,
                            "type": element.Type__c,
                            "answer": queAnsMap.get(element.Id) ? queAnsMap.get(element.Id) : ''
                        }
                        questionList.push(queObj);
                    });
    
                    this.questionList = questionList;
                    this.showspinner = false;
                    this.displayOptionA = qp;
    
                    getAnswerData({conId: this.contactId})
                    .then(result => {
                        this.answerObj = result;
                    })
                    .catch(error => {
                        console.error('Error ==> ',error.message);
                        this.showspinner = false;
                        alert('Something went wrong. Contact your interviewer.');
                    });
                }
            })
            .catch(error => {
                console.error('Error => ',error.message);
                this.showspinner = false;
                alert('Something went wrong. Contact your interviewer.');
            });
    }

    handleChange(event){
        let field = event.target.name;
        let value = event.target.value;
        
        let questionList = this.questionList;
        questionList.forEach(element => {
            if (element.count == field) {
                element.answer = value;
            }
        });
        this.questionList = questionList;
    }

    saveSingleAns(event){
        let queId = event.currentTarget.dataset.id;
        let questionList = this.questionList;
        let ans = '';
        questionList.forEach(element => {
            if (element.Id == queId) {
                ans = element.answer;
            }
        });

        saveSingleAnswer({
                ansRecId : this.answerObj.Id,
                queId: queId,
                answerData: ans
            })
            .then(result => {
                this.answerObj = result
                this.showspinner = false;
                this.successToast = true;
                setTimeout(() => this.successToast = false, 3000)
            })
            .catch(error=>{
                this.showspinner = false;
                console.error('Error => ',error.message);
                alert('Something went wrong. Contact your interviewer');
            })
    }

    openQuePopup(){
        this.confirmQuePopup = true;
    }

    closeQuePopup(){
        this.confirmQuePopup = false;
    }

    submitanswerdetails(){   
        this.stopCountdown();
        this.showspinner = true;
        let questionList = this.questionList
        let questionMap = new Map();

        questionList.forEach(element => {
            questionMap.set(String(element.Id), String(element.answer));
        });

        let answerObj = this.answerObj;
        answerObj.Answer_1__c = questionMap.get(answerObj.Question_1__c);
        answerObj.Answer_2__c = questionMap.get(answerObj.Question_2__c);
        answerObj.Answer_3__c = questionMap.get(answerObj.Question_3__c);
        answerObj.Answer_4__c = questionMap.get(answerObj.Question_4__c);
        answerObj.Answer_5__c = questionMap.get(answerObj.Question_5__c);
        answerObj.Answer_6__c = questionMap.get(answerObj.Question_6__c);

        saveAns({
                answer: answerObj,
            })
            .then(result => {
                this.showspinner = false;
                this.displayOptionA = tp;
                localStorage.removeItem("countdownTimerTime");
                localStorage.removeItem("countdownTimerTimeSeconds");
            })
            .catch(error=>{
                this.showspinner = false;
                console.error('Error => ',error.message);
                alert('Something went wrong. Contact your interviewer');
            })
    }

    closeToastModel(){
        this.successToast = false;
    }

    // ***** questionspage Page JS End *****
    // *************************************



    // **************************
    // ***** Timer JS Start *****

    resetPage() {
        this.showInputArea = true;
        this.timeVal = '';
        clearInterval(this.intervalHandle);
    }
    
        
    tick() {
        let min = Math.floor(this.secondsRemaining / 60);
        let sec = this.secondsRemaining - min * 60;
        if (sec < 10) {
            sec = '0' + sec;
        }
        this.timeVal = min.toString() + ':' + sec;
    
        localStorage.setItem('countdownTimerTime', this.timeVal);
        localStorage.setItem('countdownTimerTimeSeconds', this.secondsRemaining);
    
        if (this.secondsRemaining <= 0) {
            this.outOfTimeSubmit();
            return; // Added return statement to prevent further execution after submission
        }
        
        this.secondsRemaining--;
    
        // Auto Submit at certain time
        let currentdate = new Date(); 
    
        // Check if the current time exceeds the completion time
        const edt = new Date(Date.parse(this.examDateTime));

        // Calculate the completion time (exam time + 2 hours)
        let completionDateTime = new Date(edt.getTime() + 2 * 60 * 60 * 1000);
    
        if (currentdate >= completionDateTime) {
            this.outOfTimeSubmit();
        }
    }
    
    

    startCountdown() {
        this.showInputArea = false;
        this.intervalHandle = setInterval(() => {
            this.tick();
        }, 1000);
    }

    stopCountdown() {
        this.showInputArea = true;
        clearInterval(this.intervalHandle);
        localStorage.setItem('countdownTimerTime', this.timeVal);
    }

    outOfTimeSubmit(){
        this.showspinner = true;
        this.stopCountdown();
        let aptitudeQuestionWrapper = this.aptitudeQuestionWrapper;
        console.log('aptitudeQuestionWrapper ==> ',aptitudeQuestionWrapper);

        let rightCount = 0;
        aptitudeQuestionWrapper.forEach(element => {
            if (element.rightAnswer == element.selectedAnswer) {
                rightCount++
            }
        });
        
        this.updateAptAns();
        saveAptitudeResult({ansId: this.answerObj.Id, aptitudeMarks: rightCount})
        this.submitanswerdetails();
    }

    // ***** Timer JS End *****
    // ************************

    
}