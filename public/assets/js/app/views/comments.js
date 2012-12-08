define([
  'jquery',
  'underscore',
  'backbone',
  'lib/EventBus',
  'app/models/comment',
  'app/views/comment'
],

function(
  $,
  _,
  Backbone,
  EventBus,
  Comment,
  CommentView
) {

  return Backbone.View.extend({

    events: {
      'click #comment-btn': 'create_on_click'
    },

    initialize: function() {
      this.input = this.$('#comment');
      this.collection.bind('add', this.add_one, this);
      this.collection.bind('all', this.render, this);

      EventBus.on('conn:msg:read_comments', function(data) {
        this.collection.add(data);
      }, this);
    },

    render: function() {
      return this;
    },

    add_one: function(comment) {
      var view = new CommentView({ model: comment });
      this.$('.comment-list').append(view.render().el);
      this.$('.comment-list').scrollTop(this.$('.comment-list').prop("scrollHeight"));
    },

    add_all: function() {
      this.collection.each(this.addOne);
    },

    create_on_click: function(e) {
      e.preventDefault();
      var content = this.input.val();
      if ($.trim(content) != "") {
        (new Comment({ content: content })).save();
        this.input.val("");
      }
    }

  });

});
