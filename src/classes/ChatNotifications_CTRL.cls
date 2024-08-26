public with sharing class ChatNotifications_CTRL {
	@AuraEnabled
    public static AgentWork getWork(String workId) {
        Map<String, Schema.SObjectField> fieldMap = Schema.sObjectType.AgentWork.fields.getMap();
        String fields = String.join(new List<String>(fieldMap.keySet()), ',');
        String q = 'SELECT ServiceChannel.RelatedEntity,' + fields + ' FROM AgentWork WHERE Id = \'' + workId + '\'';
        AgentWork result = Database.query(q);
        return result;
    }
}