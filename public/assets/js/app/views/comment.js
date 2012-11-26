define([
  'jquery',
  'underscore',
  'backbone',
  'text!app/templates/comment.html'
],

function(
  $,
  _,
  Backbone,
  tpl
) {

  return Backbone.View.extend({

    tagName: 'li',
    className: 'comment',

    template: _.template(tpl),

    initialize: function() {
      this.$el.html(this.template(this.model.toJSON()));
    },

    render: function() {
      return this;
    }
  });
});
