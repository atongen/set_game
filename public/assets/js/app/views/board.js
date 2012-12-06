define([
    'jquery',
    'underscore',
    'backbone',
    'lib/EventBus',
    'lib/GlobalImageLoader',
    'app/models/cards',
    'app/models/move'
],

function(
    $,
    _,
    Backbone,
    EventBus,
    ImageLoader,
    Cards,
    Move
) {

    return Backbone.View.extend({

        ctx: null,
        cards: [],
        selected: [],
        sprite_path: '/assets/images/card_sprite.png',
        card_width: 162,
        card_height: 252,
        offset: null,
        hightlight: -1,
        highlight_fill_style: "rgba(200,200,200,0.25)",
        selected_fill_style: "rgba(100,100,100,0.5)",

        events: {
            'mouseleave': '_handle_mouse_leave',
            'mousemove':  '_handle_mouse_move',
            'click':      '_handle_click'
        },

        initialize: function(options) {
            _.bindAll(this);

            if (this.el.getContext) {
                this.offset = this.$el.offset();
                this.ctx = this.el.getContext('2d');
                ImageLoader.add(this.sprite_path, {
                    context: this,
                    fn: function(img) {}
                });

                EventBus.on('conn:msg:board', function(board) {
                    this.set_board(board);
                    this.render();
                }, this);
            }
        },

        render: function() {
            //console.log("rendering board");
            // draw card for each board slot
            _.each(this.board, function(card_id, i) {
                this._draw_card(card_id, i);
            }, this);
            // draw highlight for selected cards
            _.each(this.selected, function(card_id) {
                this._highlight_dst_id(card_id, this.selected_fill_style);
            }, this);
            // draw highligh for mouse over
            if (!_.contains(this.selected, this.highlight) && 0 <= this.highlight && this.highlight < 12) {
                this._highlight_dst_id(this.highlight, this.highlight_fill_style);
            }
        },

        set_board: function(board) {
            var selected = [];
            var new_board = _.map(board.split(':'), function(card) {
                return parseInt(card, 10);
            }, this);
            _.each(this.selected, function(idx) {
                if (new_board[idx] == this.board[idx]) {
                    // board has not changed for the selected position
                    selected.push(idx);
                }
            });
            this.selected = selected;
            this.board = new_board;
        },

        _draw_card: function(src_id, dst_id) {
            var sprite = ImageLoader.getImage(this.sprite_path);
            if (sprite) {
                var s = this._src_id_to_pix(src_id);
                var d = this._dst_id_to_pix(dst_id);
                this.ctx.drawImage(
                    sprite,
                    s.x, s.y, this.card_width, this.card_height,
                    d.x, d.y, this.card_width, this.card_height
                );
            }
        },

        _handle_click: function(e) {
            var dst_id = this._dst_pix_to_id(this._mouse_pos(e));
            var idx = _.indexOf(this.selected, dst_id);
            if (idx >= 0) {
                // card is already selected, de-select it
                this.selected.splice(idx, 1);
            } else if (this.selected.length < 3) {
                this.selected.push(dst_id);
                if (this.selected.length == 3) {
                    // get the id's of the selected cards
                    var scards = _.map(this.selected, function(bidx) {
                        return this.board[bidx];
                    }, this);
                    // check to see if they are a set
                    if (Cards.is_set(scards[0], scards[1], scards[2])) {
                        // the user has selected a set
                        var spec = _.flatten(_.zip(this.selected, scards));
                        (new Move({ spec: spec.join(":") })).save();
                    } else {
                        // the user has selected three or more cards that do not create a set
                        this.selected = [];
                    }
                }
            }
            this.render();
        },

        _handle_mouse_leave: function(e) {
            if (this.highlight != -1) {
                this.highlight = -1;
                this.render();
            }
        },

        _handle_mouse_move: function(e) {
            var highlight = this._dst_pix_to_id(this._mouse_pos(e));
            if (highlight != this.highlight) {
                this.highlight = highlight;
                this.render();
            }
        },

        _src_id_to_pix: function(src_id) {
            return {
                x: (src_id % 9) * this.card_width,
                y: Math.floor(src_id / 9) * this.card_height
            };
        },

        _dst_id_to_pix: function(dst_id) {
            return {
                x: (dst_id % 4) * this.card_width,
                y: Math.floor(dst_id / 4) * this.card_height
            };
        },

        _src_pix_to_id: function(pos) {
            // no need for this
        },

        _dst_pix_to_id: function(pos) {
            var m = Math.floor(pos.x / this.card_width);
            var n = Math.floor(pos.y / this.card_height);
            return n*4+m;
        },

        _mouse_pos: function(e) {
            var x = e.pageX - this.offset.left;
            var y = e.pageY - this.offset.top;
            return {x:x, y:y};
        },

        _highlight_dst_id: function(dst_id, fill_style) {
            var d = this._dst_id_to_pix(dst_id);
            this.ctx.fillStyle = fill_style;
            this.ctx.fillRect (d.x, d.y, this.card_width, this.card_height);
        }
    });
});
