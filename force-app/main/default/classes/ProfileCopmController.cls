public without sharing class ProfileCopmController {
    
    @AuraEnabled
    public static String getUserType(String userid){
        try {
            Id profileId = UserInfo.getProfileId();
            Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id = :profileId];
            if(userProfile.Name == 'System Administrator') {
                return 'Current User is System Administrator';
            }
            else{
                return 'Current User is not System Administrator';
            }
            
        } catch (Exception e) {
            System.debug('Error Message =>'+e.getMessage());
            return null;
        }
    }
}