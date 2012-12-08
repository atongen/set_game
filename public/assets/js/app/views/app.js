define([
    'jquery',
    'underscore',
    'backbone',
    'lib/WebSocket',
    'app/models/game',
    'app/models/player',
    'app/models/comments',
    'app/views/game',
    'app/views/player',
    'app/views/comments',
    'app/views/board'
],

function(
    $,
    _,
    Backbone,
    WebSocket,
    Game,
    Player,
    Comments,
    GameView,
    PlayerView,
    CommentsView,
    BoardView
) {

    return Backbone.View.extend({

        el: $('body'),

        initialize: function(options) {
            _.bindAll(this);

            /**
             * Setup game
             */
            this.game = new Game({ id: options.game_id });
            new GameView({
                el: '#game',
                model: this.game
            });

            /**
             * Setup player
             */
            this.player = new Player({ id: options.player_id });
            new PlayerView({
                el: '#player',
                model: this.player
            });

            /**
             * Setup comments
             */
            this.comments = new Comments();
            new CommentsView({
                el: '#comments',
                collection: this.comments
            });

            /**
             * Setup board
             */
            this.boardView = new BoardView({ el: '#board' });

            /**
             * Initialize the websocket connection
             */
            WebSocket.init();
        }
    });
});
