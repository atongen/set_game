define([
  'jquery',
  'underscore',
  'backbone',
],

function(
  $,
  _,
  Backbone
) {

    return Backbone.Model.extend({

        type: function() {
            return 'move';
        },

        defaults: {
            spec: ""
        }
    });
});
