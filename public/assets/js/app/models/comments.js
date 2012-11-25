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

  var Comments = Backbone.Collection.extend({
    model: Comment
  });

  return Comments;

});
