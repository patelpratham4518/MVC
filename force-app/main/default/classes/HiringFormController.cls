public class HiringFormController {

    public String errorMsg {get;set;}
    public Id ContId {get;set;}
    public Boolean foundId {get;set;}
    public Boolean toast {get;set;}
    public Id reqId {get; set;}
    public Id conId {get; set;}

    public HiringFormController(){
        toast = false;
        foundId = true;
        String ids = ApexPages.currentPage().getParameters().get('Id');
        ContId = ids;
        errorMsg= 'Something Went Wrong.';
    }

    public void submit(){
        
    }
}