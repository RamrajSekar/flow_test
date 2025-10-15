@isTest
private class PolicyDeadlineTrackerTest {

    @TestSetup
    static void makeData() {
        // Create test user
        Profile testProfile = [SELECT Id FROM Profile LIMIT 1];
        Long timestamp = DateTime.now().getTime();
        User testUser = new User(
            ProfileId = testProfile.Id,
            LastName = 'QaTestUser',
            Email = 'testuser' + timestamp + '@example.com',
            Username = 'testuser' + timestamp + '@example.com.test',
            CompanyName = 'QATestCompany',
            Title = 'Test',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert testUser;

        // Create Policy__c records
        List<Policy__c> policies = new List<Policy__c>();
        for (Integer i = 1; i <= 15; i++) {
            policies.add(new Policy__c(
                Name = 'Policy #' + String.valueOf(i).leftPad(3, '0'),
                Expiration_Date__c = Date.today().addDays(i <= 5 ? 2 : (i <= 10 ? 6 : 15)), // 5 at +2d, 5 at +6d, 5 at +15d
                Policy_Status__c = (i <= 10) ? 'Approved' : 'Expired',
                OwnerId = testUser.Id
            ));
        }
        insert policies;
    }

    @isTest
    static void testTrackDeadlinesHappyPath() {
        User testUser = [SELECT Id FROM User WHERE CompanyName = 'QATestCompany' LIMIT 1];

        // ✅ Proper DeadlineInput instantiation
        PolicyDeadlineTracker.DeadlineInput input = new PolicyDeadlineTracker.DeadlineInput();
        input.userId = testUser.Id;
        List<PolicyDeadlineTracker.DeadlineInput> inputs = new List<PolicyDeadlineTracker.DeadlineInput>{ input };

        Test.startTest();
        List<PolicyDeadlineTracker.DeadlineOutput> outputs = PolicyDeadlineTracker.trackDeadlines(inputs);
        Test.stopTest();

        System.assertEquals(1, outputs.size(), 'Should return one output');
        System.assertEquals(10, outputs[0].deadlines.size(), 'Should return 10 unique deadlines');
        Set<Id> policyIds = new Set<Id>();
        for (PolicyDeadlineTracker.PolicyWrapper policy : outputs[0].deadlines) {
            System.assertEquals('Approved', policy.status, 'Only Approved policies should be included');
            policyIds.add(policy.id);
        }
        System.assertEquals(10, policyIds.size(), 'No duplicates should be present');
    }

    @isTest
    static void testTrackDeadlinesNoMatch() {
        User testUser = [SELECT Id FROM User WHERE CompanyName = 'QATestCompany' LIMIT 1];

        // Expire all policies
        List<Policy__c> policies = [SELECT Id, Policy_Status__c FROM Policy__c];
        for (Policy__c p : policies) p.Policy_Status__c = 'Expired';
        update policies;

        PolicyDeadlineTracker.DeadlineInput input = new PolicyDeadlineTracker.DeadlineInput();
        input.userId = testUser.Id;
        List<PolicyDeadlineTracker.DeadlineInput> inputs = new List<PolicyDeadlineTracker.DeadlineInput>{ input };

        Test.startTest();
        List<PolicyDeadlineTracker.DeadlineOutput> outputs = PolicyDeadlineTracker.trackDeadlines(inputs);
        Test.stopTest();

        System.assertEquals(1, outputs.size(), 'Should return one output');
        System.assertEquals(0, outputs[0].deadlines.size(), 'Should return 0 deadlines when all are Expired');
    }

    @isTest
    static void testTrackDeadlinesBoundary() {
        User testUser = [SELECT Id FROM User WHERE CompanyName = 'QATestCompany' LIMIT 1];

        // Update one policy to exact 3-day threshold
        Policy__c boundaryPolicy = [SELECT Id, Expiration_Date__c FROM Policy__c WHERE Name LIKE '%001%' LIMIT 1];
        boundaryPolicy.Expiration_Date__c = Date.today().addDays(3);
        update boundaryPolicy;

        PolicyDeadlineTracker.DeadlineInput input = new PolicyDeadlineTracker.DeadlineInput();
        input.userId = testUser.Id;
        List<PolicyDeadlineTracker.DeadlineInput> inputs = new List<PolicyDeadlineTracker.DeadlineInput>{ input };

        Test.startTest();
        List<PolicyDeadlineTracker.DeadlineOutput> outputs = PolicyDeadlineTracker.trackDeadlines(inputs);
        Test.stopTest();

        System.assertEquals(1, outputs.size(), 'Should return one output');
        Boolean foundBoundary = false;
        for (PolicyDeadlineTracker.PolicyWrapper policy : outputs[0].deadlines) {
            if (policy.id == boundaryPolicy.Id) foundBoundary = true;
        }
        System.assert(foundBoundary, 'Boundary policy should be included');
    }

    @isTest
    static void testTrackDeadlinesNullUserId() {
        PolicyDeadlineTracker.DeadlineInput input = new PolicyDeadlineTracker.DeadlineInput();
        input.userId = null;
        List<PolicyDeadlineTracker.DeadlineInput> inputs = new List<PolicyDeadlineTracker.DeadlineInput>{ input };

        Test.startTest();
        List<PolicyDeadlineTracker.DeadlineOutput> outputs = PolicyDeadlineTracker.trackDeadlines(inputs);
        Test.stopTest();

        System.assertEquals(1, outputs.size(), 'Should return one output');
        System.assertEquals(0, outputs[0].deadlines.size(), 'Should return 0 deadlines with null userId');
    }
}