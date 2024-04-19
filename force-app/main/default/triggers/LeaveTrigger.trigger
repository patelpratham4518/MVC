trigger LeaveTrigger on Leave__c (before insert, after insert, after update) {

        if(Trigger.isBefore){
            if(Trigger.isInsert){
                // LeaveControllerV2.ContactAssign(trigger.new);
            }
        }
        
        if(Trigger.isAfter){
            if(Trigger.isInsert){
                // LeaveControllerV2.SendMail(trigger.new);
                LeaveControllerV2.SendMailOnApplyLeave(trigger.new);
                LeaveControllerV2.onePlusTwoScenarionMethod(trigger.new);
            }
            
            if(Trigger.isUpdate){
            //    LeaveControllerV2.SendMailLeaveUpdate(trigger.new);
               LeaveDashboardClass.ApproveMail(trigger.new);
    
            }
        }
    
    }