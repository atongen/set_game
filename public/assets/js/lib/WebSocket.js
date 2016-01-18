define([
  'jquery',
  'underscore',
  'lib/EventBus',
  'json'
],

  /**
   * Sends all websocket message to/from event bus
   */
  function(
    $,
    _,
    EventBus
  ) {

      var my = {};
      var protocol;
      var connection;

      if (location.protocol == "https:") {
          protocol = "wss:";
      } else {
          protocol = "ws:";
      }

      var path = protocol + '//' + window.location.host + window.location.pathname + '/ws';

      /**
       * Initialize the websocket connection
       */
      my.init = function() {

          /**
           * Establish connection or stub object
           */
          if (WebSocket) {
            connection = new WebSocket(path);
          } else {
            connection = {
              send: function(m){ return false },
              close: function(){}
            }
          }

          connection.onopen = function() {
            EventBus.trigger("conn:open");
          };

          connection.onclose = function() {
            EventBus.trigger("conn:close");
          };

          connection.onmessage = function(e) {
            var m = JSON.parse(e.data);
            //console.log(m);
            var type = m.type;
            var data = m.data;
            EventBus.trigger("conn:msg:" + type, data)
          };

          EventBus.on("conn:send", function(type, data) {
            my.send(type, data);
          });

          $(window).unload(function(){ connection.close(); connection = null });

      };

      my.send = function(type, data) {
        var m = { type: type };
        if (data) {
          m.data = data;
        }
        return connection.send(JSON.stringify(m, null, 2))
      };

      return my;
  }
);
