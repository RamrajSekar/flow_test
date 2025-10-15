public class PolicyDeadlineTracker {

    @AuraEnabled(cacheable=true)
    public static List<DeadlineOutput> trackDeadlines(List<DeadlineInput> inputs) {
        // Use logged-in user if no input provided
        if (inputs == null || inputs.isEmpty()) {
            inputs = new List<DeadlineInput>{ new DeadlineInput() };
            inputs[0].userId = UserInfo.getUserId();
        }

        List<DeadlineOutput> outputs = new List<DeadlineOutput>();
        Date thresholdDate = Date.today().addDays(3);

        for (DeadlineInput input : inputs) {
            DeadlineOutput output = new DeadlineOutput();
            output.deadlines = new List<PolicyWrapper>();

            // Query policies
            List<Policy__c> policies = [
                SELECT Id, Name, Policy_Status__c, Expiration_Date__c
                FROM Policy__c
                WHERE OwnerId = :input.userId
                  AND Policy_Status__c != 'Expired'
                  AND Expiration_Date__c <= :thresholdDate
                ORDER BY Expiration_Date__c ASC
            ];

            // Wrap results
            for (Policy__c p : policies) {
                PolicyWrapper wrap = new PolicyWrapper();
                wrap.id = p.Id;
                wrap.name = p.Name;
                wrap.status = p.Policy_Status__c;
                wrap.expirationDate = p.Expiration_Date__c;
                output.deadlines.add(wrap);
            }

            outputs.add(output);
        }

        return outputs;
    }

    // Input wrapper
    public class DeadlineInput {
        @AuraEnabled public Id userId;
    }

    // Output wrapper
    public class DeadlineOutput {
        @AuraEnabled public List<PolicyWrapper> deadlines;
    }

    // Individual policy wrapper
    public class PolicyWrapper {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String status;
        @AuraEnabled public Date expirationDate;
    }
}