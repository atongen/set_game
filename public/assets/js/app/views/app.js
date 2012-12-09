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
             * Setup game and player models
             */
            this.game = new Game({ id: options.game_id });
            this.player = new Player({ id: options.player_id });

            /**
             * Setup game view
             */
            new GameView({
                el: '#game',
                model: this.game,
                player: this.player
            });

            /**
             * Setup player view
             */
            new PlayerView({
                el: '#player',
                model: this.player,
                game: this.game
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
