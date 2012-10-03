$(document).ready(function () {
    var $msgs = $('#msgs');
    var events = {};

    events.say = function(e) {
      console.log(e);
      $msgs.prepend(e.data.msg + "<br />");
    }

    var ws = $.websocket('ws://' + window.location.host + window.location.pathname, {
      open: function() {
        console.log("websocket opened");
      },
      close: function() {
        console.log("websocket closed");
      },
      events: events  
    });
});
