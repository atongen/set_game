define([
    'jquery',
    'underscore',
    'backbone',
    'lib/EventBus',
    'text!app/templates/score_box.html'
],

function(
    $,
    _,
    Backbone,
    EventBus,
    tpl
) {

    return Backbone.View.extend({

        events: {},

        template: _.template(tpl),

        initialize: function() {
            _.bindAll(this);
            this.data = [];

            EventBus.on('conn:msg:update_score_box', function(data) {
                this.data = data;
                this.render();
            }, this);
        },

        render: function() {
            this.$el.html(this.template({ data: this.data }));
            return this;
        }
    });

});
