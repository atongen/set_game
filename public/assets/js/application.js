define([
    'jquery',
    'underscore',
    'websocket'
],
    function(
      $,
      _
    ) {
        var my = {};

        my.bootstrap = function() {
            // do stuff here prior to domReady
        };

        my.init = function() {
            var game_id = $('.game').data('game-id');
            if (game_id) {
              var $comments = $('.comments');
              var $board = $('#board');
              var events = {};

              events.say = function(e) {
                $comments.append(e.data + "<br />");
                $('.comments').animate({ scrollTop: $('.comments').prop("scrollHeight") }, "fast");
              };

              events.board = function(e) {
                $board.text(e.data);
              }

              events.rename_self = function(e) {
                $('#player_name').text(e.data);
              }

              events.rename_game = function(e) {
                $('#game_name').text(e.data);
              }

              var ws_path = 'ws://' + window.location.host + window.location.pathname + '/ws';
              var ws = $.websocket(ws_path, {
                open: function() {
                  console.log("websocket opened");
                },
                close: function() {
                  console.log("websocket closed");
                },
                events: events
              });

              $('#say-btn').on('click', function(e) {
                e.preventDefault();
                var $el = $('#say');
                var msg = $el.val();
                if ($.trim(msg) != "") {
                  ws.send('say', msg);
                  $el.val("");
                }
              });

              $('#test').on('click', function(e) {
                e.preventDefault();
                ws.send('move', "1:3:6:3:3:18");
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
        };

        return my;
    }
);
