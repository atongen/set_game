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
            'click #player-btn': 'trigger_player_name_modal'
        },

        initialize: function() {
            _.bindAll(this);
            this.model.bind('change', this.update_player);

            /**
             * Setup modal
             */
            this.modal = new Modal({
                id: 'player-name-modal',
                title: 'Change Your Name',
                body: "<input type='text' id='player-name-field' val='' placeholder='Change your name...'/>",
                context: this,
                submit: function(content) {
                    this.change_player_name(content);
                }
            });

            EventBus.on('conn:msg:update_player', function(data) {
                this.model.set(data);
            }, this);
        },

        render: function() {
            return this;
        },

        update_player: function() {
            this.$el.find('.player-name').text(this.model.get('name'));
            $('#player-' + this.model.id).text(this.model.get('name'));
        },

        trigger_player_name_modal: function(e) {
            e.preventDefault();
            this.modal.render();
        },

        change_player_name: function(content) {
            var name = content.find('input#player-name-field').val();
            if ($.trim(name) != "") {
                this.model.set({ name: name });
                this.model.save();
                this.modal.close();
            }
        }

    });

});
