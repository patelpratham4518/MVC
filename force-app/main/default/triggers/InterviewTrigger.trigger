trigger InterviewTrigger on Interview__c (before insert, before update, before delete, after insert, after update, after delete, after undelete){
    
    InterviewTriggerHanlder  handler =   new InterviewTriggerHanlder(trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete);
    
    if(trigger.isBefore){
        if(trigger.isInsert){
            handler.BeforeInsertEvent();
        }else if(trigger.isUpdate){
            handler.BeforeUpdateEvent();
        }else if(trigger.isDelete){
            // if(InterviewTriggerHanlder.recursion_flag_before == true){
                handler.BeforeDeleteEvent();
                // InterviewTriggerHanlder.recursion_flag_before = false;
            // }
        }
    }
    
    if(trigger.isAfter){
        if(trigger.isInsert){
            handler.AfterInsertEvent();
        }else if(trigger.isUpdate){
            handler.AfterUpdateEvent();
        }else if(trigger.isDelete){
            System.debug('after delete');
            handler.AfterDeleteEvent();
        }else if(trigger.isUndelete){
            // handler.AfterUndeleteEvent();
        }
    }
}