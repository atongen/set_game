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
      var path = 'ws://' + window.location.host + window.location.pathname + '/ws';
      var connection;

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
        console.log("ws open");
        EventBus.trigger("conn:open");
      }

      connection.onclose = function() {
        console.log("ws close");
        EventBus.trigger("conn:close");
      }

      connection.onmessage = function(e) {
        var m = JSON.parse(e.data);
        var type = m.type;
        var data = m.data;
        EventBus.trigger("conn:msg:" + type, data)
      }

      my.send = function(type, data) {
        var m = { type: type }
        if (data) {
          m.data = data;
        }
        return connection.send(JSON.stringify(m, null, 2))
      }

      $(window).unload(function(){ connection.close(); connection = null });

      return my;
  }
);
