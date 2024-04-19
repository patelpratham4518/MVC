public without sharing class Util {
public static String queryData(String ObjName, String parentFields, String conditions){
        List<sObject> dataList = new List<sObject>();
        String dString = Util.getQueryData(ObjName,parentFields);
        dString += conditions;
        return dString;
    }
    
    // To query from any object.
    public static String getQueryData(String ObjectName, String relatedFields){
        
        String query = 'SELECT ' + util.getDynamicFields(ObjectName);
        // If we have any parent fields to query pass in string format with comma seperated.
        if(relatedFields != '') query += relatedFields;
        query += ' FROM ' + ObjectName;
        
        return query;
    }
    
    // returns object's field names without parent fields.
    public static String getDynamicFields(String ObjectName){
        String fieldNames ='';
        Schema.SObjectType convertType = Schema.getGlobalDescribe().get(ObjectName);
        Map<String, Schema.SObjectField> fieldsMap = convertType.getDescribe().fields.getMap();
        Boolean isFirst = true;
        for(String key : fieldsMap.keySet()) {
            fieldNames  = isFirst   ? fieldNames + ' ' + fieldsMap.get(key)     : fieldNames + ',' + fieldsMap.get(key) + ' ';
            isFirst     = false;
        }
        return fieldNames;
    }
}