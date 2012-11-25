define([
  'jquery',
  'underscore',
  'backbone',
  'app/views/comments'
],

function(
  $,
  _,
  Backbone,
  CommentsView
) {

  return Backbone.View.extend({

    comments_view: null,
    game_id: null,
    el: $('body'),

    initialize: function(options) {
      _.bindAll(this);
      this.game_id = options.game_id;
      this.comments_view = new CommentsView();
    }
  });
});

/*
        events.say = function(e) {
          $('.comments').append(e.data + "<br />");
          $('.comments').animate({ scrollTop: $('.comments').prop("scrollHeight") }, "fast");
        };

        var bind = function() {
            $('#say-btn').on('click', function(e) {
              e.preventDefault();
              var $el = $('#say');
              var msg = $el.val();
              if ($.trim(msg) != "") {
                ws.send('say', msg);
                $el.val("");
              }
            });

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
