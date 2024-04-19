@isTest
public class intranetControllerTest{
    @isTest
    public static void employeeDetails(){
        Date d = System.today();
        intranetController ctrl = new intranetController();
        intranetController.paginationWrapper ld= new intranetController.paginationWrapper();
        
        Employee__c Employee=new Employee__c(
                                            Name='Ashish',
                                            Email__c='test@email.com',
                                            Password__c='12344',
                                            Employee_ID__c='emp',
                                            Phone__c='897989898',
                                            Last_Name__c='testend',
                                            Designation__c='tsetde'
                                         );
        insert Employee;
        
        client__c Client= new client__c(
                                            Client_Name__c='test',
                                            Email__c='test@test.com',
                                            Phone__c='978989889',
                                            Location__c='Ahmedabad',
                                            Company__c='mvclouds',
                                            Description__c='test'
                                        );
        insert Client;
        
        holiday__c Holiday=new holiday__c(
                                            Name='test',
                                            Day__c='2',
                                            Date__c=d
                                        );
        insert Holiday;
        
        Project__c Project= new Project__c(
                                            Project_Name__c='test',
                                            Start_Date__c=d,
                                            End_Date__c=d,
                                            Description__c='description',
                                            Client__c=Client.Id
                                        );
        insert Project;
        
        Module__c Module= new Module__c(
                                            Module_Name__c='Sandbox',
                                            Project__c=Project.Id,
                                            Start_Date__c=d,
                                            End_Date__c=d,
                                            Description__c='description'
                                        );
        insert Module;
        
        Task__c Task= new Task__c(
                                    Task_Name__c='Sandbox',
                                    Due_Date__c=d,
                                    Description__c='des',
                                    Completed__c=false,
                                    Module__c=Module.Id
                                );
        insert Task;
        
        Credential__c Credential= new Credential__c(
                                                        Project__c=Project.Id,
                                                        Org__c='Developer',
                                                        Username__c='test');
        insert Credential;
        
        Important_Link__c ImportantLink= new Important_Link__c(
                                                                    Topic_Name__c='test',
                                                                    URL__c='test.com'
                                                                );
        insert ImportantLink;
        
        Time_Sheet__c Timesheet= new Time_Sheet__c(
                                                    Category__c='Development',
                                                    Hours__c=2,
                                                    Employee__c=Employee.Id,
                                                    Project__c=Project.Id,
                                                    Module__c=Module.Id,
                                                    Date__c=d,
                                                    Minutes__c=10
                                                );
        insert Timesheet;
        
        Assigned_Project__c AssignetProject= new Assigned_Project__c(
                                                                        Employee__c=Employee.Id,
                                                                        Project__c=Project.Id,
                                                                        Role__c='Project Lead',
                                                                        Revoked__c=true
                                                                    );
        insert AssignetProject;
        

        Test.StartTest();

        List<Employee__c> employeeDetails = intranetController.employeeDetails();                                   //employeeDetails Mehtod
        
        List<Employee__c> employeeFullDetails = intranetController.employeeFullDetails('test');                     //employeeFullDetails Method
        
        List<Client__c> clientDetails= intranetController.clientDetails();                                          //clientDetails Method
        
        List<holiday__c> holidayDetails= intranetController.holidayDetails();                                       //holidayDetails Method
        
        List<Project__c> getProjects= intranetController.getProjects();                                             //getProjects Method
        
        List<Project__c> getFullProjectDetail= intranetController.getFullProjectDetail('test');
        
        List<Project__c> getAllProjects= intranetController.getAllProjects();
        
        List<Task__c> getFullTaskDetail= intranetController.getFullTaskDetail('test');
        
        //List<Task__c> getTaskDetails= intranetController.getTaskDetails(false,false);
        //getTaskDetails= intranetController.getTaskDetails(true,false);
        //getTaskDetails= intranetController.getTaskDetails(true,true);
        
        List<Task__c> getTaskRelatedToModule= intranetController.getTaskRelatedToModule('test','test');
        //List<Module__c> mdl= intranetController.getAllModules('test');
        //List <String> ldk=intranetController.getselectOptions(,'test');
        
        intranetController.paginationTaskWrapper wd1= intranetController.getTaskDetails(true,true,1,10,'test','test','test');
        intranetController.paginationTaskWrapper wd = intranetController.getTaskDetails(false,true,1,10,'test','test','test');
        
        //List<Task__c> searchTasks = intranetController.searchTasks('test','test','test');
        //List<Task__c> searchTasks1 = intranetController.searchTasks('','','');
        //List<Task__c> searchTasks2 = intranetController.searchTasks('','','test');
        //List<Task__c> searchTasks3 = intranetController.searchTasks('','test','test');
        //List<Task__c> searchTasks4 = intranetController.searchTasks('test','test','test');
        //List<Task__c> searchTasks5 = intranetController.searchTasks('test','','test');
        //List<Task__c> searchTasks6 = intranetController.searchTasks('','test','');
        //List<Task__c> searchTasks7 = intranetController.searchTasks('test','test','test');
        //List<Task__c> searchTasks8 = intranetController.searchTasks('test','','');
        //List<Task__c> searchTasks9 = intranetController.searchTasks('test','test','');
        
        //List<Time_Sheet__c> searchTimeSheet=intranetController.searchTimeSheet('test','test', 'test', 10, 1);
        //List<Time_Sheet__c> searchTimeSheet1=intranetController.searchTimeSheet('','', '', 10, 1);
        //List<Time_Sheet__c> searchTimeSheet2=intranetController.searchTimeSheet('','', 'test', 10, 1);
        //List<Time_Sheet__c> searchTimeSheet3=intranetController.searchTimeSheet('','test', 'test', 10, 1);
        //List<Time_Sheet__c> searchTimeSheet4=intranetController.searchTimeSheet('test','', 'test', 10, 1);
        //List<Time_Sheet__c> searchTimeSheet5=intranetController.searchTimeSheet('','test', '', 10, 1);
        //List<Time_Sheet__c> searchTimeSheet6=intranetController.searchTimeSheet('test','', '', 10, 1);
        //List<Time_Sheet__c> searchTimeSheet7=intranetController.searchTimeSheet('test','test', '', 10, 1);
        
        List<Important_Link__c> getAllTopics=intranetController.getAllTopics();
        
        list<Credential__c> credentialDetails= intranetController.credentialDetails('tst');
        list<Credential__c> searchCredentialDetails= intranetController.searchCredentialDetails('test');
        
        List<Assigned_Project__c> getAssignedEmployeeList=intranetController.getAssignedEmployeeList('test');
        Account acc=new Account(name='test');
        upsert acc;
        intranetController.revokeEmployee(AssignetProject.Id);
        
        String saveNewCredential= intranetController.saveNewCredential('test','test','test','Developer','test');
        String saveNewCredential1= intranetController.saveNewCredential('test','test','test','Sandbox','test');
        
        String createNewClient= intranetController.createNewClient('test','test','test','test','test','test');
        String createNewProject=intranetController.createNewProject('test','test','2011-01-10','2011-01-10','test');
        
        //String saveTimesheet= intranetController.saveTimesheet('Development','test','Sandbox','Sandbox','1998-01-10', '10','15','test',True);
        //String saveTimesheet1= intranetController.saveTimesheet('Development','test','Sandbox','Sandbox','1998-01-10', '10','15','test',false);
        //String saveTimesheet2= intranetController.saveTimesheet('Development','test','Sandbox','Sandbox','2211-01-10', '10','15','test',True);
        
        String saveTopics= intranetController.saveTopics('test', 'test.com');
        String createNewModule= intranetController.createNewModule();
        
        String assignedEmployeeToProject= intranetController.assignedEmployeeToProject(Project.Id,'Ashish','Project Lead');
        Delete AssignetProject;
        String assignedEmployeeToProject1= intranetController.assignedEmployeeToProject(Project.Id,'Ashish','Project Lead');
       
        List<Module__c> getAllModules= intranetController.getAllModules('test');
        
        //intranetController.paginationWrapper getTimeSheetList= intranetController.getTimeSheetList(10,3);
        List<Task__c> getTaskRelatedToModule1=intranetController.getTaskRelatedToModule('test','test');
        delete Credential; 
        String saveNewCredential2 = intranetController.saveNewCredential('test','test','test','Developer','test');
        
        Test.StopTest();

    }
  
    
}