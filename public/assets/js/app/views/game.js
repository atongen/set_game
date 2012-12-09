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

        initialize: function() {
            _.bindAll(this);
            this.model.bind('change', this.update_game);

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
            if (sets_on_board) {
                $('.sets-on-board').text(sets_on_board);
            }
            var cards_remaining = this.model.get('cards_remaining');
            if (cards_remaining) {
                $('.cards-remaining').text(cards_remaining);
            }
        },

        trigger_game_name_modal: function(e) {
            e.preventDefault();
            this.modal.render();
        },

        change_game_name: function(content) {
            var name = content.find('input#game-name-field').val();
            if ($.trim(name) != "") {
                this.model.set({ name: name });
                this.model.save();
                this.modal.close();
            }
        }
    });

});
