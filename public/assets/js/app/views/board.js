define([
    'jquery',
    'underscore',
    'backbone',
    'lib/EventBus',
    'lib/GlobalImageLoader',
    'app/models/cards'
],

function(
    $,
    _,
    Backbone,
    EventBus,
    ImageLoader,
    Cards
) {

    return Backbone.View.extend({

        ctx: null,
        cards: [],
        selected: [],
        sprite_path: '/assets/images/card_sprite.png',
        card_width: 162,
        card_heigth: 252,

        initialize: function(options) {
            _.bindAll(this);

            if (this.el.getContext) {
                this.ctx = this.el.getContext('2d');
                ImageLoader.add(this.sprite_path);

                EventBus.on('conn:msg:board', function(board) {
                    this.set_board(board);
                    this.render();
                }, this);
            }
        },

        render: function() {
            //console.log(Cards);
            //console.log(this.board);
            _.each(this.board, function(card_id) {
                console.log(Cards.get(card_id).to_s());
            });
        },

        set_board: function(board) {
            this.board = _.map(board.split(':'), function(card) {
                return parseInt(card, 10);
            }, this)
        }

    });
});
