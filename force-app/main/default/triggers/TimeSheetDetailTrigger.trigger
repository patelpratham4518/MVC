trigger TimeSheetDetailTrigger on Timesheet_Detail__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TimeSheetDetailTriggerHandler handler = new TimeSheetDetailTriggerHandler(trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.isInsert,trigger.isUpdate, trigger.isDelete, trigger.isUndelete);
    if(trigger.isBefore){
        if(trigger.isInsert){
            handler.BeforeInsertEvent();
        }else if(trigger.isUpdate){
            handler.BeforeUpdateEvent();
        }else if(trigger.isDelete){
            handler.BeforeDeleteEvent();
        }
    }else if(trigger.isAfter){
        if(trigger.isInsert){
            handler.AfterInsertEvent();
        }else if(trigger.isUpdate){
            handler.AfterUpdateEvent();
        }else if(trigger.isDelete){
            handler.AfterDeleteEvent();
        }else if(trigger.isUndelete){
            handler.AfterUndeleteEvent();
        }
    }
}