define([
  'jquery',
  'underscore',
  'backbone',
  'lib/EventBus',
  'lib/WebSocket',
  'app/models/comments',
  'app/views/comments',
  'app/views/board'
],

function(
  $,
  _,
  Backbone,
  EventBus,
  ws,
  CommentsCollection,
  CommentsView,
  BoardView
) {

  return Backbone.View.extend({

    el: $('body'),
    game_id: null,
    comments: null,
    boardView: null,

    initialize: function(options) {
      _.bindAll(this);
      this.game_id = options.game_id;

      /**
       * Setup comments
       */
      this.comments = new CommentsCollection();
      new CommentsView({
        el: '#comments',
        collection: this.comments
      });
      EventBus.on('conn:msg:read_comments', function(data) {
        this.comments.add(data);
      }, this);

      /**
       * Setup board
       */
      this.boardView = new BoardView({ el: '#board' });
    }
  });
});
