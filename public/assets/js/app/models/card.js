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
        defaults: {
            "num":   null,
            "fill":  null,
            "color": null,
            "shape": null
        },

        to_s: function() {
            return this.get('num') + ' ' +
                   this.get('fill') + ' ' +
                   this.get('color') + ' ' +
                   this.get('shape');
        }
    });
});
