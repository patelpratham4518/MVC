public class intranetController {

    public intranetController(){}
    
    @AuraEnabled
    public static List<Employee__c> employeeDetails(){
        List<Employee__c> empDetails = new List<Employee__c>();
        
        empDetails = [Select id,Name,Email__c,Employee_ID__c,Phone__c,Last_Name__c,Designation__c from Employee__c Where Active__c=true];
        return empDetails;
    }
    
    @AuraEnabled
    public static List<Employee__c> employeeFullDetails(string recordId){
        return [Select id,Name, Last_Name__c,Phone__c,Designation__c,Email__c, Employee_ID__c from Employee__c Where id =: recordId];
    }
    
    @AuraEnabled
    public static List<Client__c> clientDetails(){
        return [SELECT id,Client_Name__c FROM Client__c];
    }
    
    @AuraEnabled
    public static String createNewClient(String clientName,String clientEmail,String clientPhone,String ClientLoc,String company,String description){
        String message = '';
        List<Client__c> clientList = new List<Client__c>();
        Client__c newClient = new Client__c();
        newClient.Client_Name__c = clientName;
        newClient.Email__c = clientEmail;
        
        if(clientPhone != 'NA'){
            newClient.Phone__c = clientPhone;
        }
        if(ClientLoc != 'NA'){
            newClient.Location__c = ClientLoc;
        }
        if(company != 'NA'){
            newClient.Company__c = company;
        }
        if(description != 'NA'){
            newClient.Description__c = description;
        }
        
        clientList.add(newClient);
        System.debug('clientList == '+clientList);
        try{
            if(clientList.size()>0){
                insert clientList;
                message = 'Success';
            }else{
                message = 'Failed';
            }
        }catch(Exception e){
            message = 'Failed';
        }
        return message;
    }
    
    @AuraEnabled
    public static List<holiday__c> holidayDetails(){
        return [SELECT Id, Name, Day__c, Date__c FROM Holiday__c WHERE Date__c = THIS_YEAR ORDER BY Date__c ASC ];
    }
    
    @AuraEnabled
    public static List<Project__c> getProjects(){
        Map<Id,String> projectdetail =new Map<Id,String>();
        for(Project__c pro : [SELECT Project_Name__c,Client__r.Client_Name__c,Start_Date__c,End_Date__c,Description__c,(select id,Module_Name__c,Description__c from Modules__r) FROM Project__c]){
             System.debug(pro.Assigned_Projects__r);
        }
        return [SELECT Project_Name__c,Client__r.Client_Name__c,Start_Date__c,End_Date__c,Description__c,(select id,Module_Name__c,Description__c from Modules__r) FROM Project__c];
    }
    
    @AuraEnabled
    public static List<Project__c> getFullProjectDetail(string recordId){
        return [Select id,Project_Name__c,Project_Duration__c,Client__r.Client_Name__c,Start_Date__c,POC_Date__c,Description__c,(select id,Module_Name__c,Description__c from Modules__r) from Project__c Where Id =: recordId];
    }
    
    @AuraEnabled
    public static List<Project__c> getAllProjects(){
        return [Select Project_Name__c from Project__c];
    }
    
    @AuraEnabled
    public static String createNewProject(String projectName,String clientName,String startDate,String endDate,String Description){
        String message = '';
        List<Project__c> projectList = new List<Project__c>();
        Client__c clientId = [SELECT Id from Client__c Where Client_Name__c =: clientName];
        
        Project__c newProject = new Project__c();
        newProject.Project_Name__c = projectName;
        newProject.Client__c = clientId.Id;
        newProject.Start_Date__c = date.valueOf(startDate);
        newProject.End_Date__c = date.valueof(endDate);
        newProject.Description__c = Description;
        
        projectList.add(newProject);
        
        try{
            if(projectList.size()>0){
                insert projectList;
                message = 'Success';
            }else{
                message = 'Failed';
            }
        }catch(Exception e){
            message = 'Failed';
        }
        
        return message;
    }
    
    @AuraEnabled
    public static List<Module__c> getAllModules(string projectName){
        List<Module__c> moduleList = new List<Module__c>();
        if(projectName != 'none'){
            Project__c projectId = [Select id from Project__c Where Project_Name__c =:projectName];
            moduleList = [Select Module_Name__c from Module__c Where Project__c =: projectId.Id];
        }else{
            moduleList = [Select Id, Module_Name__c,Project__r.Project_Name__c,Start_Date__c,End_Date__c,Description__c from Module__c];
        }
        return moduleList;
    }
    
    @AuraEnabled
    public static List<Task__c> getFullTaskDetail(string recordId){
        return [select id,Name,Task_Name__c,Task__r.Task_Name__c,Due_Date__c,Employee__r.Name,Employee__r.Last_Name__c,
                Module__r.Description__c,Module__r.Module_Name__c,Description__c,Project__r.Project_Name__c from Task__c Where Id=:recordId];
    }
    
    @AuraEnabled
    public static paginationTaskWrapper getTaskDetails(boolean isCompleted,boolean allTask,Decimal pageNumber ,Integer recordToDisply,string module,string project,string emp){
        paginationTaskWrapper TaskWrapperObj = new paginationTaskWrapper();
        if(isCompleted == false && allTask == false){
            TaskWrapperObj.TaskList = [Select Due_Date__c,Name,Task_Name__c,Module__r.Description__c,Module__r.Module_Name__c,Project__r.Project_Name__c from Task__c Where Completed__c=false ORDER BY Due_Date__c];
        }else if(isCompleted == true && allTask == false){
            TaskWrapperObj.TaskList = [Select Due_Date__c,Name,Task_Name__c,Module__r.Description__c,Module__r.Module_Name__c,Project__r.Project_Name__c from Task__c Where Completed__c=true ORDER BY Due_Date__c Limit 10];
        }else{
            Integer pageSize = recordToDisply;
            Integer offset = ((Integer)pageNumber - 1) * pageSize;
            TaskWrapperObj.pageSize = pageSize;
            TaskWrapperObj.page = (Integer) pageNumber;
            // TaskWrapperObj.TaskList = [Select Due_Date__c,Name,Task_Name__c,Module__r.Description__c,Module__r.Module_Name__c,Task__r.Task_Name__c,
            //                 Project__r.Project_Name__c,Description__c,Completed__c,Employee__r.Name,Employee__r.Last_Name__c from Task__c ORDER BY Due_Date__c LIMIT :recordToDisply OFFSET :offset];
        
            String query = 'Select Due_Date__c,Task_Name__c,Module__r.Description__c,Module__r.Module_Name__c,Task__r.Task_Name__c,Project__r.Project_Name__c,Description__c,Completed__c,Employee__r.Name,Employee__r.Last_Name__c from Task__c';
            if(module == '' && project == '' && emp == ''){
                query = query;
            }
            else if(module == '' && project == '' && emp != ''){
                query += ' '+' Where Employee__r.Name Like : emp';
            }else if(module == '' && project != '' && emp != ''){
                query += ' '+' Where Project__r.Project_Name__c =:project AND Employee__r.Name Like :emp';
            }else if(module != '' && project != '' && emp != ''){
                query += ' '+' Where Project__r.Project_Name__c =:project AND Employee__r.Name Like :emp AND Module__r.Module_Name__c =:module';
            }else if(module != '' && project == '' && emp != ''){
                query += ' '+' Where Module__r.Module_Name__c =: module AND Employee__r.Name Like : emp';
            }else if(module == '' && project != '' && emp == ''){
                query += ' '+' Where Project__r.Project_Name__c =:project';
            }else if(module != '' && project == '' && emp == ''){
                query += ' '+' Where Module__r.Module_Name__c =: module';
            }else if(module != '' && project != '' && emp == ''){
                query += ' '+' Where Project__r.Project_Name__c =:project AND Module__r.Module_Name__c =:module';
            }
            
            list<Task__c> Opplistt=database.query(query);
            Integer OppNum=Opplistt.size();
            TaskWrapperObj.total=OppNum;
            query += ' '+' ORDER BY Due_Date__c DESC LIMIT :pageSize OFFSET :offset';
             TaskWrapperObj.TaskList = Database.query(query);
        }
        // Integer OppNum=TaskWrapperObj.TaskList.size();
        // TaskWrapperObj.total=OppNum;
        //Integer OppNum=Opplistt.size();
        return TaskWrapperObj;
    }
    
    @AuraEnabled
    public static List<Task__c> getTaskRelatedToModule(string projectName,string moduleName){
        
        List<Task__c> taskList = new List<Task__c>();
        Project__c projectId = [SELECT Id from Project__c WHERE Project_Name__c =: projectName];
        List<Module__c> moduleList = [SELECT Id from Module__c WHERE Project__c=:projectId.Id AND Module_Name__c =:moduleName];
        taskList = [SELECT Task_Name__c from Task__c Where Module__c IN : moduleList AND Completed__c=false];
        System.debug('Task List == >> '+taskList);
        return taskList;
    }
    
    @AuraEnabled
    public static List<Task__c> searchTasks(string module,string project,string emp){
        List<Task__c> filteredTaskList = new List<Task__c>();
        
        
        
        String query = 'Select Due_Date__c,Task_Name__c,Module__r.Description__c,Module__r.Module_Name__c,Task__r.Task_Name__c,Project__r.Project_Name__c,Description__c,Completed__c,Employee__r.Name,Employee__r.Last_Name__c from Task__c';
        
        if(module == '' && project == '' && emp == ''){
            query = query;
        }else if(module == '' && project == '' && emp != ''){
            query += ' '+' Where Employee__r.Name Like : emp';
        }else if(module == '' && project != '' && emp != ''){
            query += ' '+' Where Project__r.Project_Name__c =:project AND Employee__r.Name Like :emp';
        }else if(module != '' && project != '' && emp != ''){
            query += ' '+' Where Project__r.Project_Name__c =:project AND Employee__r.Name Like :emp AND Module__r.Module_Name__c =:module';
        }else if(module != '' && project == '' && emp != ''){
            query += ' '+' Where Module__r.Module_Name__c =: module AND Employee__r.Name Like : emp';
        }else if(module == '' && project != '' && emp == ''){
            query += ' '+' Where Project__r.Project_Name__c =:project';
        }else if(module != '' && project == '' && emp == ''){
            query += ' '+' Where Module__r.Module_Name__c =: module';
        }else if(module != '' && project != '' && emp == ''){
            query += ' '+' Where Project__r.Project_Name__c =:project AND Module__r.Module_Name__c =:module';
        }
        
        
        filteredTaskList = Database.query(query);
        return filteredTaskList; 
    }
    
    // @AuraEnabled
    // public static List<Time_Sheet__c> searchTimeSheet(string module,string project,string emp){
    // //     Integer pageSize = recordToDisply;
    // //   Integer offset = ((Integer)pageNumber - 1) * pageSize;
    //   Integer pageSize = 10;
    //   Integer offset = 1;
       
    //     List<Time_Sheet__c> filteredTimeSheetList = new List<Time_Sheet__c>();
        
    //     String query = 'SELECT Employee__r.Name,Employee__r.Last_Name__c,Category__c,Project__r.Project_Name__c,Module__r.Module_Name__c,Hours__c,Minutes__c,Date__c,Description__c FROM Time_Sheet__c';
        
    //     if(module == '' && project == '' && emp == ''){
    //         query = query;
    //     }else if(module == '' && project == '' && emp != ''){
    //         query += ' '+' Where Employee__r.Name Like : emp';
    //     }else if(module == '' && project != '' && emp != ''){
    //         query += ' '+' Where Project__r.Project_Name__c =:project AND Employee__r.Name Like :emp';
    //     }else if(module != '' && project != '' && emp != ''){
    //         query += ' '+' Where Project__r.Project_Name__c =:project AND Employee__r.Name Like :emp AND Module__r.Module_Name__c =:module';
    //     }else if(module != '' && project == '' && emp != ''){
    //         query += ' '+' Where Module__r.Module_Name__c =: module AND Employee__r.Name Like : emp';
    //     }else if(module == '' && project != '' && emp == ''){
    //         query += ' '+' Where Project__r.Project_Name__c =:project';
    //     }else if(module != '' && project == '' && emp == ''){
    //         query += ' '+' Where Module__r.Module_Name__c =: module';
    //     }else if(module != '' && project != '' && emp == ''){
    //         query += ' '+' Where Project__r.Project_Name__c =:project AND Module__r.Module_Name__c =:module';
    //     }
    //     //query +=' LIMIT :pageSize OFFSET :offset ';
    //     query += ' '+' LIMIT :pageSize OFFSET :offset';
    //     filteredTimeSheetList = Database.query(query);
    //     return filteredTimeSheetList; 
    // }
    
    @AuraEnabled
    public static paginationWrapper getTimeSheetList(string module,string project,string emp,Decimal pageNumber ,Integer recordToDisply){
        Integer pageSize = recordToDisply;
        Integer offset = ((Integer)pageNumber - 1) * pageSize;
        
        paginationWrapper timeSheetWrapperObj = new paginationWrapper();
        
        timeSheetWrapperObj.pageSize = pageSize;
        timeSheetWrapperObj.page = (Integer) pageNumber;
        // timeSheetWrapperObj.total = [SELECT count() FROM Time_Sheet__c];
        // timeSheetWrapperObj.timeSheetList = [SELECT Id,Category__c,Module__r.Module_Name__c,Employee__r.Name,Employee__r.Last_Name__c,Project__r.Project_Name__c,Description__c,
        //                                 Date__c,Hours__c,Minutes__c from Time_Sheet__c ORDER BY Date__c DESC LIMIT :recordToDisply OFFSET :offset ];
        
        
        String query = 'SELECT Employee__r.Name,Employee__r.Last_Name__c,Category__c,Project__r.Project_Name__c,Module__r.Module_Name__c,Hours__c,Minutes__c,Date__c,Description__c FROM Time_Sheet__c';
        
        if(module == '' && project == '' && emp == ''){
            query = query;
        }else if(module == '' && project == '' && emp != ''){
            query += ' '+' Where Employee__r.Name Like : emp';
        }else if(module == '' && project != '' && emp != ''){
            query += ' '+' Where Project__r.Project_Name__c =:project AND Employee__r.Name Like :emp';
        }else if(module != '' && project != '' && emp != ''){
            query += ' '+' Where Project__r.Project_Name__c =:project AND Employee__r.Name Like :emp AND Module__r.Module_Name__c =:module';
        }else if(module != '' && project == '' && emp != ''){
            query += ' '+' Where Module__r.Module_Name__c =: module AND Employee__r.Name Like : emp';
        }else if(module == '' && project != '' && emp == ''){
            query += ' '+' Where Project__r.Project_Name__c =:project';
        }else if(module != '' && project == '' && emp == ''){
            query += ' '+' Where Module__r.Module_Name__c =: module';
        }else if(module != '' && project != '' && emp == ''){
            query += ' '+' Where Project__r.Project_Name__c =:project AND Module__r.Module_Name__c =:module';
        }
        //query +=' LIMIT :pageSize OFFSET :offset ';
        list<Time_Sheet__c> Opplistt=database.query(query);
        Integer OppNum=Opplistt.size();
        timeSheetWrapperObj.total=OppNum;
        query += ' '+' ORDER BY Date__c DESC LIMIT :pageSize OFFSET :offset';
        timeSheetWrapperObj.timeSheetList = Database.query(query);
        
        
        return timeSheetWrapperObj;
        // return [SELECT Id,Category__c,Module__r.Module_Name__c,Employee__r.Name,Employee__r.Last_Name__c,Project__r.Project_Name__c,Description__c,Date__c,Hours__c,Minutes__c from Time_Sheet__c];
    }
    
    @AuraEnabled
    public static List<Important_Link__c> getAllTopics(){
        return [SELECT id,Name,Topic_Name__c,URL__c FROM Important_Link__c];
    }
    
    @AuraEnabled
    public static List<Credential__c> credentialList(String credentialName){
        
        String query = ' SELECT Id,Org__c,Login_URL__c,Password__c,Project__r.Project_Name__c,Redirect_Login__c'
                     + ' , Security_Token__c,Username__c from Credential__c';
        
        if(String.isNotBlank(credentialName) && String.isNotEmpty(credentialName)){
            query += ' WHERE Project__r.Project_Name__c LIKE \'%' +credentialName+ '%\'';
        }
        return Database.query(query);
    }
    
    @AuraEnabled
    public static List<Credential__c> credentialDetails(String Ids){
        return [SELECT Id,Org__c,Login_URL__c,Password__c,Project__r.Project_Name__c,Redirect_Login__c,
                Security_Token__c,Username__c from Credential__c Where Id =:Ids];
    }
  
    @AuraEnabled
    public static List<Credential__c> searchCredentialDetails(string projectName){
        Project__c projectId = [SELECT Id from Project__c WHERE Project_Name__c =: projectName];
        
        return [SELECT Id,Org__c,Login_URL__c,Password__c,Project__r.Project_Name__c,Redirect_Login__c,
                Security_Token__c,Username__c from Credential__c Where Project__c =:projectId.Id];
    }
    
    @AuraEnabled
    public static String saveNewCredential(String project,String username,String password,String org,String securityToken){
        System.debug('Project '+project);
        List<Credential__c> credentialList = new List<Credential__c>();
        String message = '';
        Project__c projectName = [SELECT id FROM Project__c WHERE Project_Name__c =: project];
        
        Credential__c newCredential = new Credential__c();
        newCredential.Project__c = projectName.Id;
        newCredential.Username__c = username;
        newCredential.Password__c = password;
        newCredential.Org__c = org;
        if(org == 'Developer' || org == 'Production'){
            newCredential.Login_URL__c = 'https://login.salesforce.com/';
            newCredential.Redirect_Login__c = 'https://login.salesforce.com?un='+username+ '&pw=' +password;
        }else if(org == 'Sandbox'){
            newCredential.Login_URL__c = 'https://test.salesforce.com/';
            newCredential.Redirect_Login__c = 'https://test.salesforce.com?un='+username+ '&pw=' +password;
        }
        
        if(securityToken != 'NA'){
            newCredential.Security_Token__c = securityToken;
        }
        
        //https://login.salesforce.com?un=dharmik.shah@focalcxm.com&pw=merckjune2018
        credentialList.add(newCredential);
        
        try{
            if(credentialList.size()>0){
                insert newCredential;
                message = 'Success';
            }
        }catch(Exception e){
            message = 'Failed'; 
        }
        
        return message;
    }
    
    @AuraEnabled
    public static String saveTimesheet(String category,String project,String module,String task,String selectedDate,
                                       String hours,String minutes,String description,Boolean taskStatus){
        String message = '';
        Date d=Date.valueOf(selectedDate);
        Date d2=System.today();
        d2=d2.addDays(1);
        if(d>d2){
            message='You cannot choose greater date by next day !';
        }else{
            User oUser = [select id,Name,TimeZoneSidKey,Username,Alias,Country,Email,FirstName,LastName,IsActive,IsPortalEnabled,Title,CompanyName 
                 FROM User Where id =: userInfo.getUserId()];
            String name=oUser.FirstName;
            List<Time_Sheet__c> timeSheetList = new List<Time_Sheet__c>();
            Time_Sheet__c timesheet = new Time_Sheet__c();
            Project__c projectName = [SELECT id from Project__c WHERE Project_Name__c =:project];    
            Employee__c employeeName = [SELECT Id from Employee__c WHERE Name =:name];
            
            timesheet.Category__c = category;
            timesheet.Project__c = projectName.Id;
            timesheet.Employee__c = employeeName.Id;
            timesheet.Date__c = Date.valueOf(selectedDate);
            timesheet.Hours__c = Integer.valueof(hours);
            timesheet.Minutes__c = Integer.valueOf(minutes);
            
            if(module != 'NA'){
                Module__c moduleName = [SELECT Id from Module__c WHERE Module_Name__c =: module];
                timesheet.Module__c = moduleName.Id;
            }
            
            if(task != 'NA'){
                Task__c taskName = [SELECT Id from Task__c WHERE Task_Name__c =: task];
                timesheet.Task__c = taskName.Id;
            }
            if(description != null){
                timesheet.Description__c = description;
            }
            timeSheetList.add(timesheet);
            try{
                if(timeSheetList.size()>0){
                    insert timeSheetList;
                    if(taskStatus == true){
                        message = updateTaskStatus(task);
                    }else{
                        message = 'Records has been Saved Successfully';
                    }
                }
            }catch(Exception e){
                message = 'Failed';
            }
        }
        
        return message;
        
    }
    
    private static String updateTaskStatus(String taskName){
        String message = '';
        Task__c task = [Select id,Task_Name__c,Completed__c from Task__c WHERE Task_Name__c =: taskName];
        task.Completed__c = true;
        
        try{
            update task;
            message = 'Success';
        }catch(Exception e){
            message = 'Failed';
        }
        return message;
    }
    
    @AuraEnabled
    public static String saveTopics(string topicName,string url){
        String message = '';
        List<Important_Link__c> topicList = new List<Important_Link__c>();
        Important_Link__c topic = new Important_Link__c();
        
        topic.Topic_Name__c = topicName;
        topic.URL__c = url;
        
        topicList.add(topic);
        
        try{
            if(topicList.size()>0){
                insert topicList;
                message = 'Success';
            }
        }catch(Exception e){
            message = 'Failed';
        }
        return message;
        
    }
    
    @AuraEnabled
    public static String createNewModule(){
        String message = '';
        return message;
    }
    
    @AuraEnabled
    public static List<Assigned_Project__c> getAssignedEmployeeList(String projectId){
        return [SELECT Id,Employee__r.Name,Role__c,Project__r.Project_Name__c from Assigned_Project__c 
                Where Project__c =: projectId AND Revoked__c = false];
    }
    
    @AuraEnabled
    public static void revokeEmployee(String assignedEmpId){
        Assigned_Project__c assignedEmp = new Assigned_Project__c();
        assignedEmp = [SELECT id,Revoked__c from Assigned_Project__c WHERE Id =: assignedEmpId];
        assignedEmp.Revoked__c = true;
        try{
            update assignedEmp;
        }catch(Exception e){
            
        }
    }
    
    @AuraEnabled
    public static String assignedEmployeeToProject(String projectName,String empName,String role){
        
        String message = '';
        List<Assigned_Project__c> assignedEmpList = new List<Assigned_Project__c>();
        System.debug('projectName '+projectName);
        Project__c project = [SELECT Id,Project_Name__c FROM Project__c WHERE Id =: projectName];
        Employee__c employee = [SELECT Id from Employee__c WHERE Name =: empName];
        
        Assigned_Project__c assignEmp = new Assigned_Project__c();
        assignEmp.Project__c = project.Id;
        assignEmp.Employee__c = employee.Id;
        assignEmp.Role__c = role;
        assignEmp.Revoked__c = false;
        
        assignedEmpList.add(assignEmp);
        
        try{
            System.debug('response.getReturnValue()    '+assignedEmpList);
            if(assignedEmpList.size() > 0){
                insert assignedEmpList;
                message = 'Success';
            }else{
                message = 'Failed';
            }
        }catch(Exception e){
            message = 'Failed';
        }
        return message;
    }
    
    @AuraEnabled
    public static List <String> getselectOptions(sObject objObject, string fld) {
    system.debug('objObject --->' + objObject);
    system.debug('fld --->' + fld);
    List < String > allOpts = new list < String > ();
    // Get the object type of the SObject.
    Schema.sObjectType objType = objObject.getSObjectType();
    
    // Describe the SObject using its object type.
    Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
    
    // Get a map of fields for the SObject
    map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
    
    // Get the list of picklist values for this field.
    list < Schema.PicklistEntry > values =
    fieldMap.get(fld).getDescribe().getPickListValues();
    
    // Add these values to the selectoption list.
    for (Schema.PicklistEntry a: values) {
    allOpts.add(a.getValue());
    }
    system.debug('allOpts ---->' + allOpts);
    allOpts.sort();
    return allOpts;
    }

    public class paginationWrapper {
        @AuraEnabled public Integer pageSize {get;set;}
        @AuraEnabled public Integer page {get;set;}
        @AuraEnabled public Integer total {get;set;}
        @AuraEnabled public List<Time_Sheet__c> timeSheetList {get;set;}
    }
    public class paginationTaskWrapper {
        @AuraEnabled public Integer pageSize {get;set;}
        @AuraEnabled public Integer page {get;set;}
        @AuraEnabled public Integer total {get;set;}
        @AuraEnabled public List<Task__c> TaskList {get;set;}
    }
     
    //Calender component methods
    
    @AuraEnabled
    public static list<Times__c> getAllEvents(){
        Date conditionDate = System.Today() - 91;
        list<Times__c> eventlist = [SELECT Id, Hours__c, Date__c, Hours_Minutes__c FROM Times__c WHERE Date__c >: conditionDate];
        return eventlist;
    }
    @AuraEnabled
    public static list<Holiday__c> getAllHoliday(){
        list<Holiday__c> Holidaylist = [SELECT Id,Date__c FROM Holiday__c ];
        return Holidaylist;
    }
    
    @AuraEnabled
    public static void updateEvent(string eventid,string eventdate){
    system.debug(eventid);
        system.debug(eventdate);
        string eventdatelist = eventdate.replace('T',' ');
       
  system.debug(eventdatelist);
    Event e= new event(id = eventid);
    e.StartDateTime = DateTime.valueof(eventdatelist);
    update e;
   
    }
}