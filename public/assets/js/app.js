var ws = new WebSocket('ws://' + window.location.host + window.location.pathname);

$(document).ready(function () {
    var my = {};
    var $msgs = $('#msgs');
    var seriesData = [ [ { x: 0, y: 0 } ] ];
    var palette = new Rickshaw.Color.Palette( { scheme: 'classic9' } );

    var graph = new Rickshaw.Graph( {
      element: document.getElementById("chart"),
      width: 900,
      height: 500,
      renderer: 'area',
      stroke: true,
      series: [
        {
          color: palette.color(),
          data: seriesData[0],
          name: 'Thing'
        }
      ]
    } );

    graph.render();

    my.say = function (msg) {
      $msgs.prepend(msg + "<br />");
    }

    my.update = function(x, y) {
      my.say("updating: [" + x + "," + y + "]");
      seriesData[0].push({ x: x, y: y*1000 });
      graph.update();
    };

    ws.onopen = function () {
      my.say('websocket opened');
    };

    ws.onclose = function () {
      my.say('websocket closed');
    };

    ws.onmessage = function (m) {
      var sep = m.data.indexOf(":");
      var cmd = m.data.substring(0,sep);
      if (cmd) {
        if (my[cmd]) {
          var args = m.data.substring(sep+1).split(",");
          my[cmd].apply(this, args);
        } else {
          console.log(cmd + " not a function.");
        }
      } else {
        console.log(m.data + " has not cmd.");
      }
    };


    var sender = function (f) {
        var input = document.getElementById('input');
        input.onclick = function () {
            input.value = ""
        };
        f.onsubmit = function () {
            ws.send(input.value);
            input.value = "send a message";
            return false;
        }
    }(document.getElementById('form'));
});
