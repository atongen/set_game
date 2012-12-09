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
    'app/views/board',
    'app/views/score_box'
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
    BoardView,
    ScoreBoxView
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
            new BoardView({
                el: '#board',
                game: this.game
            });

            /**
             * Setup score box
             */
            new ScoreBoxView({ el: '#score-box' });

            /**
             * Initialize the websocket connection
             */
            WebSocket.init();
        }
    });
});
