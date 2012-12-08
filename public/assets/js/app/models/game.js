define([
    'jquery',
    'underscore',
    'backbone'
],

function(
    $,
    _,
    Backbone
) {

    return Backbone.Model.extend({

        type: function() {
            return 'game';
        },

        defaults: function() {
            return {
                name: "Game #" + this.id
            };
        }
    });
});
