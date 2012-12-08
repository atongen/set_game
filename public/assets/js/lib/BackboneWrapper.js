define([
  'jquery',
  'underscore',
  'backbone_vendor',
  'lib/EventBus'
],

  /**
   * Wrapper to override backbone sync method
   */
  function(
    $,
    _,
    Backbone,
    EventBus
  ) {

    Backbone.sync = function(method, model, options) {
      var result = false;

      // module must respond to type method
      var type = model.type();
      if (type) {
        switch (method) {
          case 'read':
            break;
          case 'create':
            EventBus.trigger("conn:send", "create_" + type, model.attributes);
            result = true;
            break;
          case 'update':
            EventBus.trigger("conn:send", "update_" + type, model.attributes);
            result = true;
            break;
          case 'delete':
            EventBus.trigger("conn:send", "delete_" + type, model.id);
            result = true;
            break;
        }
      }

      if (result && _.isFunction(options.success)) {
        options.success.call(null);
      } else if (!result && _.isFunction(options.error)) {
        options.error.call(null);
      }
    };

    return Backbone;
  }
);
