public class MassDeleteRecords implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{ 

    private String objName;

    public MassDeleteRecords(String objectName) {
        objName = objectName;
    }

    public List<sObject> start(Database.BatchableContext info){ 
        System.debug('MassDeleteRecords Start');
        List<sObject> objList = new List<sObject>();

        if (objName != null) {
            String query = 'SELECT Id, Name FROM '+objName;
            objList = Database.query(query);
        }

        System.debug('objList ==> '+objList);
        System.debug('objList Length => '+objList.size());
        return objList; 
    }

    public void execute(Database.BatchableContext info, List<sObject> objList){
        System.debug('MassDeleteRecords Execute');
        // delete objList;
    }

    public void finish(Database.BatchableContext info){     
        System.debug('MassDeleteRecords Finish');
    }

}