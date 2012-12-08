define([
  'jquery',
  'underscore',
  'backbone',
  'app/models/comment'
],

function(
  $,
  _,
  Backbone,
  Comment
) {

  return Backbone.Collection.extend({
    model: Comment
  });

});
