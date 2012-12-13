define([
    'jquery',
    'underscore',
    'backbone',
    'lib/EventBus',
    'lib/Modal'
],

function(
    $,
    _,
    Backbone,
    EventBus,
    Modal
) {

    return Backbone.View.extend({

        events: {
            'click #game-btn': 'trigger_game_name_modal'
        },

        initialize: function(options) {
            _.bindAll(this);
            this.player = options.player;

            /**
             * Setup modal
             */
            this.modal = new Modal({
                id: 'game-name-modal',
                title: 'Change Game Name',
                body: "<input type='text' id='game-name-field' val='' placeholder='Change game name...'/>",
                context: this,
                submit: function(content) {
                    this.change_game_name(content);
                }
            });

            EventBus.on('conn:msg:update_game', function(data) {
                this.model.set(data);
                this.update_game();
            }, this);
        },

        render: function() {
            return this;
        },

        update_game: function() {
            var name = this.model.get('name');
            if (name) {
                $('.game-name').text(name);
            }
            var sets_on_board = this.model.get('sets_on_board');
            if (_.isNumber(sets_on_board) && sets_on_board >= 0) {
                $('.sets-on-board').text(sets_on_board);
            }
            var cards_remaining = this.model.get('cards_remaining');
            if (_.isNumber(cards_remaining) && cards_remaining >= 0) {
                $('.cards-remaining').text(cards_remaining);
            }
            var state = this.model.get('state');
            if (state) {
                if (state == 'new') {
                    var btn = $('<button>', { class: 'btn btn-success btn-large btn-block btn-start' });
                    btn.text("Start Game");
                    var model = this.model;
                    btn.on('click', function(e) {
                        e.preventDefault();
                        model.set({ state: 'started' });
                        model.save();
                    });
                    $('#status-btn').html(btn);
                } else if (state == 'waiting') {
                    var btn = $('<button>', { class: 'btn btn-warning btn-large btn-block btn-wait' });
                    btn.text("Waiting to Start");
                    $('#status-btn').html(btn);
                } else if (state == 'started') {
                    var btn = $('<button>', { class: 'btn btn-large btn-block btn-stall' });
                    btn.text("I'm Stuck!");
                    var model = this.model;
                    btn.on('click', function(e) {
                        e.preventDefault();
                        model.set({ state: 'stalled' });
                        model.save();
                    });
                    $('#status-btn').html(btn);
                } else if (state == 'stalled') {
                    var btn = $('<button>', { class: 'btn btn-warning btn-large btn-block btn-stall' });
                    btn.text("You've Stalled Out!");
                    $('#status-btn').html(btn);
                } else if (state == 'complete') {
                    $('#status-btn').html("");
                }
            }
        },

        trigger_game_name_modal: function(e) {
            e.preventDefault();
            if (this._is_creator()) {
                this.modal.render();
            }
        },

        change_game_name: function(content) {
            if (this._is_creator()) {
                var name = content.find('input#game-name-field').val();
                if ($.trim(name) != "") {
                    this.model.set({ name: name });
                    this.model.save();
                    this.update_game();
                    this.modal.close();
                }
            }
        },

        _is_creator: function() {
            return this.player.get('id') == this.model.get('creator_id');
        }
    });

});
