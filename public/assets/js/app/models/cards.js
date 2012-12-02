define([
    'jquery',
    'underscore',
    'backbone',
    'app/models/card'
],

/**
 * A static class that contains a list of cards
 * Cards should be ordered in the same way as they are
 * ordered in lib/rt/Card.rb
 *
 * This allows us to refer to unique cards by ids as ints on both
 * server and client
 */
function(
    $,
    _,
    Backbone,
    Card
) {
    var NUM   = [ 'one',  'two',     'three'  ];
    var FILL  = [ 'open', 'shaded',  'solid'  ];
    var COLOR = [ 'red',  'blue',    'green'  ];
    var SHAPE = [ 'oval', 'diamond', 'bowtie' ];

    var Cards = Backbone.Collection.extend({
        model: Card,

        compararator: function(card) {
            return card.get("id");
        },

        is_set: function(id1, id2, id3) {
            _.all(['num', 'fill', 'color', 'shape'], function(attr) {
                var c1 = this.get(id1);
                var c2 = this.get(id2);
                var c3 = this.get(id3);

                return (
                    // either all attributes are the same...
                    c1.get(attr) == c2.get(attr) &&
                    c2.get(attr) == c3.get(attr)
                ) || (
                    // or they're all different...
                    c1.get(attr) != c2.get(attr) &&
                    c2.get(attr) != c3.get(attr) &&
                    c1.get(attr) != c3.get(attr)
                );
            }, this);
        }
    });

    return new Cards(_.map(_.range(81), function(id) {
        var v = id.toString(3);
        while (v.length < 4) {
            v = '0' + v;
        }
        var n = _.map(v.split(""), function(c) {
            return parseInt(c, 10)
        });
        return {
            id:    id,
            num:   NUM[n[0]],
            fill:  FILL[n[1]],
            color: COLOR[n[2]],
            shape: SHAPE[n[3]]
        };
    }));
});
