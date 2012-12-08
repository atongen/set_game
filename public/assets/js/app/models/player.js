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
            return 'player';
        },

        defaults: function() {
            return {
                name: "Player #" + this.id
            };
        }
    });
});
