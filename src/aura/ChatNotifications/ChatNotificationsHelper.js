({
    createNotification : function(body, isPersistent=false, isAudible=false) {
        if (!window.Notification) {
            console.error('Browser does not support notifications.');
        }
        else if (Notification.permission !== 'granted') {
            console.error('User has not granted notification permission.');
        }
        else {
            var notify = new Notification('Salesforce', {
            	body: body,
            	icon: '/resource/1589498392000/slds_icons/standard/live_chat_120.png',
            	requireInteraction: isPersistent
            });
            var audio = new Audio('/presence/audio/request.mp3');
            if (isAudible) audio.play();
            notify.onclick = function(event) {
                window.focus();
            };
        }
    }
})