define([
    'jquery',
    'underscore',
    'backbone',
    'lib/EventBus'
],

function(
    $,
    _,
    Backbone,
    EventBus
) {

    return Backbone.View.extend({

        events: {
        },

        initialize: function() {
            _.bindAll(this);
            this.model.bind('change', this.update_game);

            EventBus.on('conn:msg:update_game', function(data) {
                this.model.set(data);
            }, this);
        },

        render: function() {
            return this;
        },

        update_game: function() {
            $('.game-name').text(this.model.get('name'));
        }

    });

});
