({
    initialize : function(component, event, helper) {
        if (window.Notification) {
            Notification.requestPermission().then(function(p) {
            	if (p !== 'granted') {
                    throw new Error('Notifications not allowed by user.');
                }
            }).catch(function (e) {
                console.error(e);
            });
        }
    },
    
    onLoginSuccess : function(component, event, helper) {
        //var statusId = event.getParam('statusId');
    },
    
    onStatusChanged : function(component, event, helper) {
        //var channels = event.getParam('channels');
        //var statusId = event.getParam('statusId');
        //var statusName = event.getParam('statusName');
        //var statusApiName = event.getParam('statusApiName');
    },
    
    onWorkAssigned : function(component, event, helper) {
        console.log('Work assigned.');
        //var workItemId = event.getParam('workItemId');
        //var workId = event.getParam('workId');
        var action = component.get('c.getWork');
        action.setParams({
            'workId': event.getParam('workId')
        });
        action.setCallback(this, function(response) {
            console.log(response.getReturnValue().ServiceChannel.RelatedEntity);
            var serviceChannel = response.getReturnValue().ServiceChannel.RelatedEntity;
            if (serviceChannel == 'LiveChatTranscript') {
                helper.createNotification('Incoming visitor!', true, true);
            }
        });
        $A.enqueueAction(action);
    },
    
    onWorkAccepted : function(component, event, helper) {
        //var workItemId = event.getParam('workItemId');
        //var workId = event.getParam('workId');
    },
    
    onLogout : function(component, event, helper) {
        helper.createNotification('Logged out.');
    },
  
})