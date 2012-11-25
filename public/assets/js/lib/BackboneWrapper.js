define([
  'jquery',
  'underscore',
  'backbone_vendor',
  'lib/WebSocket'
],

  /**
   * Wrapper to override backbone sync method
   */
  function(
    $,
    _,
    Backbone,
    ws
  ) {

    Backbone.sync = function(method, model, options) {
      var result = [];

      // module must respond to type method
      var type = model.type();
      if (type) {
        switch (method) {
          case 'read':
            result[0] = false;
            result[1] = { message: "Cannot request read." }
            break;
          case 'create':
            result[0] = true;
            result[1] = ws.send("create_" + type, model.attributes);
            break;
          case 'update':
            result[0] = true;
            result[1] = ws.send("update_" + type, model.attributes);
            break;
          case 'delete':
            result[0] = true;
            result[1] = ws.send("delete_" + type, model.id);
            break;
        }
      } else {
        result[0] = false;
        result[1] = { message: "No type for model given." };
      }

      if (result[0] && _.isFunction(options.success)) {
        options.success.call(null, result[1]);
      } else if (!result[0] && _.isFunction(options.error)) {
        options.error.call(null, result[1]);
      }
    }

    return Backbone;
  }
);
