public class pdfview {
    
    public static Attachment attach{get;set;}
    public static String attacheId{get;set;}
    public static String attachname{get;set;}
    public static Blob  attachbody {get;set;}
    public string pdfvalue {get;set;}
    public Id idvalue {get;set;}
    public pdfview(){
        attacheId = '00P6F000039Z8ccUAC';
        idvalue = ApexPages.currentPage().getParameters().get('id');
        attach = [Select Id,Name,Body,ContentType from Attachment WHERE Id =:attacheId LIMIT 1]; 
        attachbody = attach.Body;
        attachname = attach.Name;
        pdfvalue = '';
        pdfvalue = EncodingUtil.Base64Encode(attachbody);
   }
  

}