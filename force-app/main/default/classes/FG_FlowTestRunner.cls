public with sharing class FG_FlowTestRunner {
    
    @AuraEnabled
    public static Flow_Test_Result__c runFlowTest(String flowApiName){
        Flow_Test_Result__c result = new Flow_Test_Result__c();
        try {
            Datetime startTime = System.now();

            // Run The flow
            Flow.Interview interview = Flow.Interview.CreateInterview(flowApiName, new Map<String, Object>());
            interview.start();
            
            // Calc Execution Duration
            Long exe_duration = System.now().getTime() - startTime.getTime();

            // Prepare result record
            result.Status__c = 'Passed';
            result.Log_Details__c = 'Flow Executed Successfully: ' + flowApiName;
            result.Execution_Duration_ms__c = exe_duration;

        } catch (Exception e) {
            result.Status__c = 'Failed';
            result.Log_Details__c = 'Flow Execution Failed: ' + e.getMessage();
        }

        result.Run_Date_Time__c = System.now();

        //Associate with Flow_Test__c
        Flow_Test__c parent_test = [SELECT Id FROM Flow_Test__c Where Flow_Name__c =:flowApiName LIMIT 1];
        result.Flow_Test__c = parent_test.Id;
        result.Run_By__c = UserInfo.getUserId();

        insert result;
        return result;
    }

}