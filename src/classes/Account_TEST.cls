@isTest
public class Account_TEST {
    
    @isTest
    public static void testBeforeUpdateSumsSingleContact() {
        Account a = new Account(
            Name = 'Test Account'
        );
        insert a;
        Contact c = new Contact(
        	AccountId = a.Id,
            LastName = 'Test Contact'
        );
        
        Test.startTest();
        insert c;
        Test.stopTest();
        
        List<Account> testResults = [SELECT NumberOfContacts__c FROM Account WHERE Id = :a.Id];
        System.assertEquals(1, testResults[0].NumberOfContacts__c);
    }
    
    @isTest
    public static void testBeforeUpdateIgnoresUnrelatedContacts() {
        Account a1 = new Account(
            Name = 'Test Account 1'
        );
        insert a1;
        Account a2 = new Account(
            Name = 'Test Account 2'
        );
        insert a2;
        Contact c = new Contact(
        	AccountId = a1.Id,
            LastName = 'Test Contact'
        );
        
        Test.startTest();
        insert c;
        Test.stopTest();
        
        List<Account> testResults = [SELECT NumberOfContacts__c FROM Account WHERE Id = :a2.Id];
        System.assertEquals(0, testResults[0].NumberOfContacts__c);
    }
    
    @isTest
    public static void testBeforeUpdateSumsManyContacts() {
        Account a = new Account(
            Name = 'Test Account'
        );
        insert a;
        List<Contact> contactList = new List<Contact>();
        for (Integer i = 0; i < 2000; i++) {
        	Contact c = new Contact(
        		AccountId = a.Id,
            	LastName = 'Test Contact ' + i
        	);
            contactList.add(c);
        }
        
        Test.startTest();
        insert contactList;
        Test.stopTest();
        
        List<Account> testResults = [SELECT NumberOfContacts__c FROM Account WHERE Id = :a.Id];
        System.assertEquals(2000, testResults[0].NumberOfContacts__c);
    }
}