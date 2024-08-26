({
    setRecordId : function(component, event, helper) {
        var flow = component.find("flow");
        var recordId = component.get("v.recordId");
        if (recordId) {
	        var args = [
    	        {
        	        name : "recordId",
            	    type : "String",
                	value : recordId
	            }
    	    ];
        	flow.startFlow("PostToCurrentRecordUtility", args);
        }
    },
    
    resetFlow : function(component, event, helper) {
    	var flow = component.find("flow");
        flow.destroy();
        $A.createComponent(
            "lightning:flow",
            {
                "aura:id" : "flow",
            },
            function(newFlow, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(newFlow);
                    component.set("v.body", body);
                    var setRecordId = component.get("c.setRecordId");
                    $A.enqueueAction(setRecordId);
                }
            }
        );
    }
})