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

  var Comment = Backbone.Model.extend({

    type: function() {
      return 'comment';
    },

    defaults: function() {
      return {
        author: null,
        created_at: null,
        content: null
      };
    }
  });

  return Comment;

});
