public class WebinarController {

    public string fname {get;set;}
    public string lname {get;set;}
    public string eml {get;set;}
    public string phoneNumber {get;set;}
    public string PrefixNumber {get;set;}
    public string company {get;set;}
    public string profession {get;set;}
    public boolean error {get;set;}
    public string errormsg {get;set;}
    public boolean thankyou {get;set;}
    public Id WebinarId {get;set;}
    public webinar__c Webi {get;set;}
    public boolean WebiTime {get;set;}
    // CONTROLLER
    public WebinarController(){
        error = false;
        errormsg ='';
        thankyou = true;
        WebinarId = ApexPages.currentPage().getParameters().get('Id');
        WebiTime = false;
        WebinarDescription();
        
    }

    public void WebinarDescription(){        
        Webi = [SELECT Id,Webinar_Description__c,WebinarTime__c FROM webinar__c WHERE Id =: WebinarId];
    }

    public void create(){
        
        List<webinarAttendee__c> leadList = new List<webinarAttendee__c>();
        leadList = [SELECT Id,Name FROM webinarAttendee__c WHERE webinarlLead__r.Email =: eml AND webinar__c =: WebinarId];
        
        System.debug('hey');
        if(leadList.size() > 0){
            // Email already registered
            error = true;
            errormsg = 'This email is already registered.';
            
        }else if(!Pattern.matches('[a-zA-Z0-9._-]+@[a-zA-Z]+.[a-zA-Z]{2,4}', eml)){
            error = true;
            errormsg='Please Enter Valid Email Address.';
        }else if(!Pattern.matches('^[7-9][0-9]{9}$',phoneNumber)){
            error=true;
            errormsg = 'Please Enter Valid Phone Number';
        }
        else{            
                error = false;
                Lead lead = new Lead();        
                lead.Company = company;
                lead.Profession__c = profession;
                lead.Phone = PrefixNumber+' '+phoneNumber;
                lead.Email = eml;
                lead.FirstName = fname;
                lead.LastName = lname;

                insert lead;

                webinarAttendee__c wa = new webinarAttendee__c();
                wa.webinarlLead__c = lead.Id;
                wa.webinar__c	  = WebinarId ;
                insert wa;

                if(Webi.WebinarTime__c < System.now()){
                    WebiTime = true;
                }
                    thankyou = true;
                

                

                String subjectGmail = 'Verify your email address';
            // String bodyGmail = 'Dear '+ConObj.FirstName+',<br /><br />Thank you for Registration.<br />A representative will contact you shortly.<br /><br />Best always,<br />MV Clouds<br /><br /><a href="https://mvclouds.com">Mv Clouds</a>';
            String bodyGmail = '<html><head><meta content="text/html; charset=utf-8" http-equiv="Content-Type"><meta name="viewport" content="width=device-width,initial-scale=1"><style type="text/css">body{margin:0;background:#FEFEFE;color:#585858}table{font-size:15px;line-height:23px;max-width:500px;min-width:460px;text-align:center}.table_inner{min-width:100%!important}td{font-family:-apple-system,BlinkMacSystemFont,Roboto,sans-serif;vertical-align:top}.carpool_logo{margin:30px auto}.dummy_row{padding-top:20px!important}.section,.sectionlike{background:#00ccff}.section{padding:0 20px}.sectionlike{padding-bottom:10px}.section_content{width:100%;background:#fff}.section_content_padded{padding:0 35px 40px}.section_zag{background:#F4FBF9}.imageless_section{padding-bottom:20px}img{display:block;margin:0 auto}.img_section{width:100%;max-width:500px}.img_section_side_table{width:100%!important}h1{font-size:20px;font-weight:500;margin-top:40px;margin-bottom:0}.near_title{margin-top:10px}.last{margin-bottom:0}a{color:#63D3CD;font-weight:500;word-break:break-word}.button{display:block;width:100%;max-width:300px;background:#20DA9C;border-radius:8px;color:#fff;font-size:18px;font-weight:400;padding:12px 0;margin:30px auto 0;text-decoration:none}small{display:block;width:100%;max-width:330px;margin:14px auto 0;font-size:14px}.signature{padding:20px}.footer,.footer_like{background:#1FD99A}.footer{padding:0 20px 30px}.footer_content{width:100%;text-align:center;font-size:12px;line-height:initial;color:#005750}.footer_content a{color:#005750}.footer_item_image{margin:0 auto 10px}.footer_item_caption{margin:0 auto}.footer_legal{padding:20px 0 40px;margin:0;font-size:12px;color:#A5A5A5;line-height:1.5}.text_left{text-align:left}.text_right{text-align:right}.va{vertical-align:middle}.stats{min-width:auto!important;max-width:370px;margin:30px auto 0}.counter{font-size:22px}.stats_counter{width:23%}.stats_image{width:18%;padding:0 10px}.stats_meta{width:59%}.stats_spaced{padding-top:16px}.walkthrough_spaced{padding-top:24px}.walkthrough{max-width:none}.walkthrough_meta{padding-left:20px}.table_checkmark{padding-top:30px}.table_checkmark_item{font-size:15px}.td_checkmark{width:24px;padding:7px 12px 0 0}.padded_bottom{padding-bottom:40px}.marginless{margin:0}@media only screen and (max-width:480px) and (-webkit-min-device-pixel-ratio:2){table{min-width:auto!important}.section_content_padded{padding-right:25px!important;padding-left:25px!important}.counter{font-size:18px!important}}</style></head><body style="margin:0;background:#FEFEFE;color:#585858"><span class="preheader" style="display:none!important;visibility:hidden;opacity:0;color:transparent;height:0;width:0;border-collapse:collapse;border:0"></span><table align="center" border="0" cellspacing="0" cellpadding="0" style="font-size:15px;line-height:23px;max-width:500px;min-width:460px;text-align:center"><tbody><tr style="background:rgba(0,204,255,0.1) !important;"><td style="font-family:-apple-system,BlinkMacSystemFont,Roboto,sans-serif;vertical-align:top;border:none!important"><img src="https://i.ibb.co/k3PBQCh/mvlogo.png" class="carpool_logo" width="232" style="display:block;margin:0 auto;margin:30px auto"></td></tr><tr><td class="sectionlike imageless_section" style="font-family:-apple-system,BlinkMacSystemFont,Roboto,sans-serif;vertical-align:top;border:none!important;background:#00ccff;padding-bottom:10px;padding-bottom:20px"></td></tr><tr><td class="section" style="font-family:-apple-system,BlinkMacSystemFont,Roboto,sans-serif;vertical-align:top;border:none!important;background:#00ccff;padding:0 20px"><table border="0" cellspacing="0" cellpadding="0" class="section_content" style="font-size:15px;line-height:23px;max-width:500px;min-width:460px;text-align:center;width:100%;background:#fff"><tbody><tr><td class="section_content_padded" style="font-family:-apple-system,BlinkMacSystemFont,Roboto,sans-serif;vertical-align:top;border:none!important;padding:0 35px 40px"><h1 style="font-size:20px;font-weight:500;margin-top:40px;margin-bottom:0">Hi '+lead.FirstName+' '+lead.LastName+',</h1><p class="near_title last" style="margin-top:10px;margin-bottom:0">Please verify that your email address is '+Lead.Email+', and that you entered it when signing up for Webinar.</p><a href="https://dharmikmvclouds-developer-edition.ap4.force.com/WebinarThankYou?Id='+WebinarId+'&Lead='+Lead.Id+'" style="display:block;width:100%;max-width:300px;background:#00ccff;border-radius:8px;color:#fff;font-size:18px;padding:12px 0;margin:30px auto 0;text-decoration:none" target="_blank">Verify email</a> <small style="display:block;width:100%;max-width:330px;margin:14px auto 0;font-size:14px">After verifying the email, you will get a Google meet invite from which you can join the Webinar. If you have any query or Doubts feel free to write us back at info@mvclouds.com</small></td></tr></tbody></table></td></tr><tr><td class="section" style="font-family:-apple-system,BlinkMacSystemFont,Roboto,sans-serif;vertical-align:top;border:none!important;background:#00ccff;padding:0 20px"><table border="0" cellspacing="0" cellpadding="0" class="section_content section_zag" style="font-size:15px;line-height:23px;max-width:500px;min-width:460px;text-align:center;width:100%;background:#fff;background:#F4FBF9"><tbody><tr><td class="signature" style="font-family:-apple-system,BlinkMacSystemFont,Roboto,sans-serif;vertical-align:top;border:none!important;padding:20px"><p class="marginless" style="margin:0">Happy Webinar,<br>The MV Clouds Team</p></td></tr></tbody></table></td></tr><tr><td class="section dummy_row" style="font-family:-apple-system,BlinkMacSystemFont,Roboto,sans-serif;vertical-align:top;border:none!important;background:#00ccff;padding:0 20px;padding-top:20px!important"></td></tr></tbody></table></body></html>';
            String sendTo = fname+ ' ' + lname + '<'+ eml +'>';            
            GoogleGmailApi.sendGmail(subjectGmail,bodyGmail,sendTo);



            }            
        }
        
        public void ValidEmail(){
            error= true;
            errormsg = 'Please Enter Valid Email Address.';
        }
        public void EmailBack(){
            error= false;
            errormsg = '';
        }
}