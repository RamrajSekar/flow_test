public class CreateTestPolicies {
    public Integer policyCount;

    public CreateTestPolicies(Integer policyCount) {
        this.policyCount = 50;
    }

    public static void createPolicies(Integer policyCount) {
        List<String> policyNames = new List<String>();
        for(Integer i= 1; i <= policyCount; i++)
        {
            policyNames.add('Policy #' + String.valueOf(i).leftPad(3, '0'));
        }
        Set<String> existingNames = new Set<String>();
        for (Policy__c p : [
            SELECT Name FROM Policy__c WHERE Name IN :policyNames AND Policy_Status__c!='Expired'
        ]) {
            existingNames.add(p.Name);
        }
        List<Policy__c> policies = new List<Policy__c>();
        Integer counter = 1;
        for (String policyName : policyNames) {
            counter++;
            if (!existingNames.contains(policyName)) {
                System.debug(policyName+' - Will Be Added'); 
                if (counter<=20){
                    policies.add(new Policy__c(
                    Name = policyName,
                    Expiration_Date__c = Date.today().addDays(Math.mod(counter, 15)),
                    OwnerId = UserInfo.getUserId(),
                    Policy_Status__c='Approved'
                    ));
                }
                else {
                    policies.add(new Policy__c(
                    Name = policyName,
                    Expiration_Date__c = Date.today().addDays(Math.mod(counter, 15)),
                    OwnerId = UserInfo.getUserId(),
                    Policy_Status__c='In Review'
                    ));
                }
                
            }
        }
        insert policies;
        // Below is working code
        // List<Policy__c> policies = new List<Policy__c>();
        // for (Integer i = 1; i <= policyCount; i++) {
        //     policies.add(new Policy__c(
        //         Name = 'Policy #' + String.valueOf(i).leftPad(3, '0'),
        //         Expiration_Date__c = Date.today().addDays(Math.mod(i, 15)),
        //         OwnerId = UserInfo.getUserId()
        //     ));
        // }
        // insert policies;
    }

    public static void deletePolicies(){
        List<Policy__c> policies = [SELECT Id FROM Policy__c];
        if(!policies.isEmpty())
        {
            delete policies;
        }
    }
}