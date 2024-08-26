public with sharing class Account_TRGR {
    
    List<Account> records {get;set;}
    Map<Id, Account> oldValues {get;set;}
    
    public Account_TRGR(List<Account> records) {
        this(records, null);
    }
    
    public Account_TRGR(List<Account> newList, List<Account> oldList) {
        records = newList;
        oldValues = (oldList == null)
            ? new Map<Id, Account>()
            : new Map<Id, Account>(oldList);
    }
    
    public void onBeforeUpdate() {
        sumNumberOfContacts();
    }
    
    //sum number of account's direct child contacts
    private void sumNumberOfContacts() {
        Map<Id, Account> setAccounts = new Map<Id, Account>(records);
        for (Id aId : setAccounts.keySet()) {
            setAccounts.get(aId).NumberOfContacts__c = 0;
        }
        List<Contact> listContacts = [select AccountId from Contact where AccountId in: setAccounts.keySet()];
        for (Contact c : listContacts) {
            setAccounts.get(c.AccountId).NumberOfContacts__c++;
        }
    }
}