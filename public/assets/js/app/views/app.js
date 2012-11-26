define([
  'jquery',
  'underscore',
  'backbone',
  'lib/EventBus',
  'lib/WebSocket',
  'app/models/comments',
  'app/views/comments'
],

function(
  $,
  _,
  Backbone,
  EventBus,
  ws,
  CommentsCollection,
  CommentsView
) {

  return Backbone.View.extend({

    comments: null,
    game_id: null,
    el: $('body'),

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
    }
  });
});

/*

            $('#move-btn').on('click', function(e) {
              e.preventDefault();
              var $el = $('#move');
              ws.send('move', $el.val());
              $el.val("");
            });

            $('#invite-btn').on('click', function(e) {
              e.preventDefault();
              var $el = $('#invite');
              ws.send('invite', $el.val());
              $el.val("");
            });

            $('#rename-self-btn').on('click', function(e) {
              e.preventDefault();
              var $el = $('#rename-self');
              ws.send('rename_self', $el.val());
              $el.val("");
            });

            $('#rename-game-btn').on('click', function(e) {
              e.preventDefault();
              var $el = $('#rename-game');
              ws.send('rename_game', $el.val());
              $el.val("");
            });
        }

        */
