define([
  'jquery',
  'underscore',
  'backbone',
  'app/models/comment',
  'app/views/comment'
],

function(
  $,
  _,
  Backbone,
  Comment,
  CommentView
) {

  var CommentsView = Backbone.View.extend({

    events: {
      'click #comment-btn': 'createOnClick'
    },

    initialize: function() {
      this.input = this.$('#comment');
      this.collection.bind('add', this.addOne, this);
      this.collection.bind('all', this.render, this);
    },

    render: function() {
      return this;
    },

    addOne: function(comment) {
      var view = new CommentView({ model: comment });
      this.$('.comment-list').append(view.render().el);
      this.$('.comment-list').scrollTop(this.$('.comment-list').prop("scrollHeight"));
    },

    addAll: function() {
      this.collection.each(this.addOne);
    },

    createOnClick: function(e) {
      e.preventDefault();
      var content = this.input.val();
      if ($.trim(content) != "") {
        (new Comment({ content: content })).save();
        this.input.val("");
      }
    }

  });

  return CommentsView;

});
