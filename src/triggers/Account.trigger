trigger Account on Account (before update) {
    switch on Trigger.operationType {
        when BEFORE_UPDATE {
            Account_TRGR handler = new Account_TRGR(Trigger.new);
            handler.onBeforeUpdate();
        }
    }
}