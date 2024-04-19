public class DateTimePickerController{
    /*A Public Property that stores the value from the InputText on the Visualforce Page*/
    public String DateTimeField{
        get;
        set;
    }
    
    /*Action Method invoked from a CommandButton on the Visualforce Page*/
   /* public void UpdateDateTime(){
        UPDATE 
            new Interview__c(
                Id = '00Q9000000UQzdT', 
                Date__c = DateTime.parse(DateTimeField)
            );
    }*/
}