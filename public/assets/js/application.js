define([
],
    function() {
        var my = {};

        my.bootstrap = function() {
            // do stuff here prior to domReady
        };

        my.init = function() {
            console.log("hello");
        };

        return my;
    }
);

/*
$(document).ready(function () {
    var $msgs = $('#msgs');
    var events = {};
    var selected = [];

    events.say = function(e) {
      //console.log(e);
      $msgs.prepend(e.data.msg + "<br />");
    };

    var ws = $.websocket('ws://' + window.location.host + window.location.pathname, {
      open: function() {
        console.log("websocket opened");
      },
      close: function() {
        console.log("websocket closed");
      },
      events: events  
    });

    $('#button').on('click', function(e) {
      e.preventDefault();
      var msg = $('#input').val();
      if ($.trim(msg) != "") {
        ws.send('say', { msg: msg });
      }
    });

    for (var i = 0; i++; i < 12) {
        console.log('wow', i);
        (function(n) {
            console.log('yo', n);
            $('#' + n).on('click', function(e) {
                console.log('now', n);
                if (selected[n]) {
                    $(this).removeClass('selected');
                    selected[n] = false;
                } else {
                    $(this.addClass('selected'));
                    selected[n] = true;
                }
            });
        }(i))
    }
});
*/