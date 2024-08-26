@RestResource(urlMapping='/Account/*/findLeadsToConvert')
global class AccountFindLeadsToConvert {
    @HttpPatch
    global static ConvertedLead convertLead () {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        string accountId = req.requestURI.substringBetween('/Account/', '/findLeadsToConvert');
        
        List<Account> listA = [
            select Id, Name, Website, WebsiteText__c, Hostname__c
            from Account
            where Id = :accountId
            limit 1
        ];
        if (listA.isEmpty()) {
            return new ConvertedLead('Account not found.');
        }
        Account A = listA[0];
        
        Lead L = getLeadFromAccount(A);
        if (L.Id == null) {
            return new ConvertedLead('No matching leads found.');
        }
        Contact C = getContactFromLeadAndAccount(L, A);
        Opportunity O = getOpportunityFromAccount(A);
        return convert(L, A, C, O);
    }
    
    global class ConvertedLead {
        global Boolean success { get; set; }
        global List<String> errors { get; set; }
        global Id leadId { get; set; }
        global Id accountId { get; set; }
        global Id contactId { get; set; }
        global Id opportunityId { get; set; }
        
        global ConvertedLead (String error) {
            success = false;
            errors = new List<String>();
            errors.add(error);
        }
        
        global ConvertedLead (Database.LeadConvertResult lcr) {
            accountId = lcr.getAccountId();
            contactId = lcr.getContactId();
            leadId = lcr.getLeadId();
            opportunityId = lcr.getOpportunityId();
            success = lcr.isSuccess();
            errors = new List<String>();
            for (Database.Error e : lcr.getErrors()) {
                errors.add(e.getMessage());
            }
        }
    }
    
    private static Lead getLeadFromAccount (Account A) {
        List<Lead> listL = [
            select Id, OwnerId, Name, FirstName, LastName, Email, Website, WebsiteText__c
            from Lead
            where IsConverted = false and (Website != '' and Website = :A.Website)
            order by Id asc nulls last
            limit 1
        ];
        return listL.isEmpty()
            ? searchLeadFromAccount(A)
            : listL[0];
    }
    
    private static Lead searchLeadFromAccount (Account A) {
        List<Lead> listL = new List<Lead>();
        string query = buildLeadQuery(A);
        List<List<SObject>> search = [
            find :query
            returning Lead(Id, OwnerId, Name, FirstName, LastName, Email, Hostname__c where IsConverted = false)
            limit 1
        ];
        listL = search[0];
        return listL.isEmpty()
            ? new Lead()
            : listL[0];
    }
    
    private static string buildLeadQuery (Account A) {
        List<String> fields = new List<String>();
        if (String.isNotBlank(A.Hostname__c)) {
            fields.add(A.Hostname__c);
        }
        return String.join(fields, ' or ');
    }
    
    private static Contact getContactFromLeadAndAccount (Lead L, Account A) {
        List<Contact> listC = [
            select Id
            from Contact
            where AccountId != '' and AccountId = :A.Id and ((Name != '' and Name = :L.Name) or (Email != '' and Email = :L.Email))
            limit 1
        ];
        return listC.isEmpty()
            ? searchContactFromLeadAndAccount(L, A)
            : listC[0];
    }
    
    private static Contact searchContactFromLeadAndAccount (Lead L, Account A) {
        List<Contact> listC = new List<Contact>();
        string query = buildContactQuery(L, A);
        List<List<SObject>> search = [
            find :query
            returning Contact(Id where AccountId != '')
            limit 1
        ];
        listC = search[0];
        return listC.isEmpty()
            ? new Contact()
            : listC[0];
    }
    
    private static string buildContactQuery (Lead L, Account A) {
        List<String> fields = new List<String>();
        fields.add(L.Name);
        if (String.isNotBlank(L.Email)) {
            fields.add(L.Email);
        }
        fields.add('"' + A.Name + '"');
        return String.join(fields, ' ');
    }
    
    private static Opportunity getOpportunityFromAccount (Account A) {
        List<Opportunity> listO = [
            select Id
            from Opportunity
            where AccountId != '' and AccountId = :A.Id
            limit 1
        ];
        return listO.isEmpty()
            ? new Opportunity()
            : listO[0];
    }
    
    private static ConvertedLead convert (Lead L, Account A, Contact C, Opportunity O) {
        Database.LeadConvert lc = new Database.LeadConvert();
        LeadStatus convertedStatus = [select MasterLabel from LeadStatus where IsConverted = true limit 1];
        lc.setConvertedStatus(convertedStatus.MasterLabel);
        lc.setDoNotCreateOpportunity(O.Id == null);
        
        if (L.Id != null) lc.setLeadId(L.Id);
        if (A.Id != null) lc.setAccountId(A.Id);
        if (C.Id != null) lc.setContactId(C.Id);
        if (O.Id != null) lc.setOpportunityId(O.Id);
        
        /*
         * At this time, there are no supported methods to fetch any type of
         * default lead owner from Setup. We must explicitly set the owner of
         * the converted records if the lead owner is not a User, i.e. a queue.
         * Instead of relying on user IDs, we can use the default owner of
         * guest-created records from our Force.com root site as a configuration
         * setting.
         */
        if (L.OwnerId.getSObjectType() != Schema.User.getSObjectType()) {
            Site S = [
                select GuestRecordDefaultOwnerId
                from Site
                where Status='Active' and SiteType='Visualforce' and UrlPathPrefix=''
                limit 1
            ];
            lc.setOwnerId(S.GuestRecordDefaultOwnerId);
        }
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        return new ConvertedLead(lcr);
    }
}