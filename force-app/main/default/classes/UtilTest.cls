@isTest
private class UtilTest {

    @isTest
    static void testQueryData() {
        // Create test records
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;

        // Query data using Util class
        String query = Util.queryData('Account', '', 'WHERE Id = \'' + testAccount.Id + '\'');
        List<sObject> dataList = Database.query(query);

        // Verify query result
        System.assertEquals(1, dataList.size());
        System.assertEquals(testAccount.Id, dataList[0].Id);
    }

    @isTest
    static void testGetQueryData() {
        // Call getQueryData with sample object and related fields
        String query = Util.getQueryData('Account', ', Name');
        String expectedQuery = 'SELECT Id, Name FROM Account';
        
        // Verify the query string
        System.assertEquals(expectedQuery, query);
    }

    @isTest
    static void testGetDynamicFields() {
        // Call getDynamicFields with Account object
        String fields = Util.getDynamicFields('Account');
        
        // Verify the fields string contains 'Id' and 'Name'
        System.assert(fields.contains('Id'));
        System.assert(fields.contains('Name'));
    }

}