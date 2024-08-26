@isTest
global class AccountFindLeadsToConvert_TEST {
    @isTest
    static void convertInvalidLeadExpectFailure() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        req.requestURI = '/services/apexrest/Account/x/findLeadsToConvert';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        AccountFindLeadsToConvert.ConvertedLead status = AccountFindLeadsToConvert.convertLead();
        Test.stopTest();
        
        System.assertEquals(false, status.success);
    }

    @isTest
    static void convertConvertedLeadExpectFailure() {
        Account A = new Account(
            Name = 'Test Account',
            Website = 'website.test'
        );
        insert A;
        Lead L = new Lead(
            FirstName = 'Test',
            LastName = 'Person',
            Company = 'Test Company',
            Website = 'website.test',
            IsConverted = true
        );
        insert L;
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(L.Id);
        lc.setAccountId(A.Id);
        lc.setConvertedStatus('Converted');
        Database.convertLead(lc);

        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        req.requestURI = '/services/apexrest/Account/' + A.Id + '/findLeadsToConvert';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        AccountFindLeadsToConvert.ConvertedLead status = AccountFindLeadsToConvert.convertLead();
        
        Test.stopTest();
        
        L = [select IsConverted, ConvertedAccountId from Lead where Id = :L.Id];
        System.assertEquals(false, status.success);
        System.assertEquals('No matching leads found.', status.errors[0]);
        System.assertEquals(true, L.IsConverted);
    }

    @isTest
    static void convertLeadWithAccount() {
        Lead L = new Lead(
            FirstName = 'Test',
            LastName = 'Person',
            Company = 'Test Company',
            Website = 'website.test'
        );
        insert L;
        Account A = new Account(
            Name = 'Test Account',
            Website = 'website.test'
        );
        insert A;
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        req.requestURI = '/services/apexrest/Account/' + A.Id + '/findLeadsToConvert';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        AccountFindLeadsToConvert.ConvertedLead status = AccountFindLeadsToConvert.convertLead();
        
        Test.stopTest();
        
        L = [select IsConverted, ConvertedAccountId from Lead where Id = :L.Id];
        System.assertEquals(true, status.success);
        System.assertEquals(true, L.IsConverted);
        System.assertEquals(A.Id, L.ConvertedAccountId);
    }
    
    @isTest
    static void convertLeadFuzzyAccount() {
        Lead L = new Lead(
            FirstName = 'Test',
            LastName = 'Person',
            Company = 'Test Company',
            Website = 'website.test'
        );
        insert L;
        Account A = new Account(
            Name = 'Test Account',
            Website = 'www.website.test'
        );
        insert A;
        List<Id> i = new List<Id>();
        i.add(L.Id);
        Test.setFixedSearchResults(i);
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        req.requestURI = '/services/apexrest/Account/' + A.Id + '/findLeadsToConvert';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        AccountFindLeadsToConvert.ConvertedLead status = AccountFindLeadsToConvert.convertLead();
        
        Test.stopTest();
        
        L = [select IsConverted, ConvertedAccountId from Lead where Id = :L.Id];
        System.assertEquals(true, status.success);
        System.assertEquals(true, L.IsConverted);
        System.assertEquals(A.Id, L.ConvertedAccountId);
    }
    
    @isTest
    static void convertLeadWithoutWebsite() {
        Lead L = new Lead(
            FirstName = 'Test',
            LastName = 'Person',
            Company = 'Test Company',
            Email = 'test@example.com'
        );
        insert L;
        Account A = new Account(
            Name = 'Test Account'
        );
        insert A;
        List<Id> i = new List<Id>();
        i.add(L.Id);
        Test.setFixedSearchResults(i);
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        req.requestURI = '/services/apexrest/Account/' + A.Id + '/findLeadsToConvert';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        AccountFindLeadsToConvert.ConvertedLead status = AccountFindLeadsToConvert.convertLead();
        
        Test.stopTest();
        
        L = [select IsConverted, ConvertedAccountId from Lead where Id = :L.Id];
        System.assertEquals(true, status.success);
        System.assertEquals(true, L.IsConverted);
        System.assertEquals(A.Id, L.ConvertedAccountId);
    }
    
    @isTest
    static void convertLeadAvoidContact() {
        Lead L = new Lead(
            FirstName = 'Test',
            LastName = 'Person',
            Company = 'Test Company',
            Website = 'website.test'
        );
        insert L;
        Account A = new Account(
            Name = 'Test Account',
            Website = 'different-website.test'
        );
        insert A;
        Contact C = new Contact(
            FirstName = 'Test',
            LastName = 'Person',
            AccountId = A.Id
        );
        insert C;
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        req.requestURI = '/services/apexrest/Account/' + A.Id + '/findLeadsToConvert';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        AccountFindLeadsToConvert.ConvertedLead status = AccountFindLeadsToConvert.convertLead();
        
        Test.stopTest();
        
        L = [select IsConverted, ConvertedAccountId, ConvertedContactId from Lead where Id = :L.Id];
        System.assertEquals(false, status.success);
        System.assertEquals(false, L.IsConverted);
        System.assertNotEquals(A.Id, L.ConvertedAccountId);
        System.assertNotEquals(C.Id, L.ConvertedContactId);
    }
    
    @isTest
    static void convertLeadWithAccountAndContact() {
        Lead L = new Lead(
            FirstName = 'Test',
            LastName = 'Person',
            Company = 'Test Company',
            Website = 'website.test'
        );
        insert L;
        Account A = new Account(
            Name = 'Test Account',
            Website = 'website.test'
        );
        insert A;
        Contact C = new Contact(
            FirstName = 'Test',
            LastName = 'Person',
            AccountId = A.Id
        );
        insert C;
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        req.requestURI = '/services/apexrest/Account/' + A.Id + '/findLeadsToConvert';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        AccountFindLeadsToConvert.ConvertedLead status = AccountFindLeadsToConvert.convertLead();
        
        Test.stopTest();
        
        L = [select IsConverted, ConvertedAccountId, ConvertedContactId from Lead where Id = :L.Id];
        System.assertEquals(true, status.success);
        System.assertEquals(true, L.IsConverted);
        System.assertEquals(A.Id, L.ConvertedAccountId);
        System.assertEquals(C.Id, L.ConvertedContactId);
    }
    
    @isTest
    static void convertLeadWithFuzzyAccountAndContact() {
        Lead L = new Lead(
            FirstName = 'Test',
            LastName = 'Person',
            Company = 'Test Company',
            Website = 'website.test'
        );
        insert L;
        Account A = new Account(
            Name = 'Test Account',
            Website = 'www.website.test'
        );
        insert A;
        Contact C = new Contact(
            FirstName = 'Test',
            LastName = 'Pearson',
            AccountId = A.Id
        );
        insert C;
        List<Id> i = new List<Id>();
        i.add(L.Id);
        i.add(A.Id);
        i.add(C.Id);
        Test.setFixedSearchResults(i);
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        req.requestURI = '/services/apexrest/Account/' + A.Id + '/findLeadsToConvert';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        AccountFindLeadsToConvert.ConvertedLead status = AccountFindLeadsToConvert.convertLead();
        
        Test.stopTest();
        
        L = [select IsConverted, ConvertedAccountId, ConvertedContactId from Lead where Id = :L.Id];
        System.assertEquals(true, status.success);
        System.assertEquals(true, L.IsConverted);
        System.assertEquals(A.Id, L.ConvertedAccountId);
        System.assertEquals(C.Id, L.ConvertedContactId);
    }
    
    @isTest
    static void convertLeadWithMultipleAccounts() {
        Lead L = new Lead(
            FirstName = 'Test',
            LastName = 'Person',
            Company = 'Test Company',
            Website = 'website.test'
        );
        insert L;
        Account A_NotAMatch = new Account(
            Name = 'Test Account',
            Website = 'website.test'
        );
        insert A_NotAMatch;
        Account A = new Account(
            Name = 'Test Account',
            Website = 'website.test'
        );
        insert A;
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        req.requestURI = '/services/apexrest/Account/' + A.Id + '/findLeadsToConvert';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        AccountFindLeadsToConvert.ConvertedLead status = AccountFindLeadsToConvert.convertLead();
        
        Test.stopTest();
        
        L = [select IsConverted, ConvertedAccountId from Lead where Id = :L.Id];
        System.assertEquals(true, status.success);
        System.assertEquals(true, L.IsConverted);
        System.assertEquals(A.Id, L.ConvertedAccountId);
        System.assertNotEquals(A_NotAMatch.Id, L.ConvertedAccountId);
    }
    
    @isTest
    static void convertLeadWithAccountContactOpportunity() {
        Lead L = new Lead(
            FirstName = 'Test',
            LastName = 'Person',
            Company = 'Test Company',
            Website = 'website.test'
        );
        insert L;
        Account A = new Account(
            Name = 'Test Account',
            Website = 'website.test'
        );
        insert A;
        Contact C = new Contact(
            FirstName = 'Test',
            LastName = 'Person',
            AccountId = A.Id
        );
        insert C;
        Opportunity O = new Opportunity(
        	Name = 'Test Opportunity',
        	StageName = 'Open',
        	CloseDate = Date.today()+1,
        	AccountId = A.Id
        );
        insert O;
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        req.requestURI = '/services/apexrest/Account/' + A.Id + '/findLeadsToConvert';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        AccountFindLeadsToConvert.ConvertedLead status = AccountFindLeadsToConvert.convertLead();
        
        Test.stopTest();
        
        L = [select IsConverted, ConvertedAccountId, ConvertedContactId, ConvertedOpportunityId from Lead where Id = :L.Id];
        System.assertEquals(true, status.success);
        System.assertEquals(true, L.IsConverted);
        System.assertEquals(A.Id, L.ConvertedAccountId);
        System.assertEquals(C.Id, L.ConvertedContactId);
        System.assertEquals(O.Id, L.ConvertedOpportunityId);
    }
    
    @isTest
    static void convertLeadWithPredefinedIds() {
        Lead L = new Lead(
            FirstName = 'Test',
            LastName = 'Person',
            Company = 'Test Company',
            Website = 'website.test'
        );
        insert L;
        Account A = new Account(
            Name = 'Test Account',
            Website = 'website.test'
        );
        insert A;
        Contact C = new Contact(
            FirstName = 'Test',
            LastName = 'Person',
            AccountId = A.Id
        );
        insert C;
        Opportunity O = new Opportunity(
        	Name = 'Test Opportunity',
        	StageName = 'Open',
        	CloseDate = Date.today()+1,
        	AccountId = A.Id
        );
        insert O;
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        req.requestURI = '/services/apexrest/Account/' + A.Id + '/findLeadsToConvert';
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf('{"accountId":"' + A.Id + '","contactId":"' + C.Id + '","opportunityId":"' + O.Id + '"}');
        RestContext.request = req;
        RestContext.response = res;
        AccountFindLeadsToConvert.ConvertedLead status = AccountFindLeadsToConvert.convertLead();
        
        Test.stopTest();
        
        L = [select IsConverted, ConvertedAccountId, ConvertedContactId, ConvertedOpportunityId from Lead where Id = :L.Id];
        System.assertEquals(true, status.success);
        System.assertEquals(true, L.IsConverted);
        System.assertEquals(A.Id, L.ConvertedAccountId);
        System.assertEquals(C.Id, L.ConvertedContactId);
        System.assertEquals(O.Id, L.ConvertedOpportunityId);
    }
    
    @isTest
    static void convertLeadOwnedByQueue() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
        	Group Q = new Group(
        		Name = 'Test Queue',
	        	Type = 'Queue'
    	    );
        	insert Q;
	        QueueSobject QS = new QueueSobject(
    	    	QueueId = Q.Id,
        	    SobjectType = 'Lead'
	        );
    	    insert QS;
    	}
        Group Q = [select Id from Group where Name='Test Queue'];
        Lead L = new Lead(
            FirstName = 'Test',
            LastName = 'Person',
            Company = 'Test Company',
            Website = 'website.test',
            OwnerId = Q.Id
        );
        insert L;
        Account A = new Account(
            Name = 'Test Account',
            Website = 'website.test'
        );
        insert A;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        req.requestURI = '/services/apexrest/Account/' + A.Id + '/findLeadsToConvert';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        AccountFindLeadsToConvert.ConvertedLead status = AccountFindLeadsToConvert.convertLead();
        Test.stopTest();
        
        L = [select IsConverted from Lead where Id = :L.Id];
        System.assertEquals(true, status.success);
        System.assertEquals(true, L.IsConverted);
    }
}