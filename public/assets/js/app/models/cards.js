define([
    'jquery',
    'underscore',
    'backbone',
    'app/models/card'
],

/**
 * A static class that contains a list of cards
 * Cards should be ordered in the same way as they are
 * ordered in lib/set_game/Card.rb
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

        /**
         * By default, cards are ordered by id
         */
        compararator: function(card) {
            return card.get("id");
        },

        /**
         * Takes three ids and returns bool if set or not
         */
        is_set: function(id1, id2, id3) {
            if (_.all([id1, id2, id3], function(id) { return 0 <= id && id < 81; })) {
                return this._is_card_set(
                    this.get(id1),
                    this.get(id2),
                    this.get(id3)
                );
            } else {
                return false;
            }
        },

        /**
         * Loop through all combinations of the card ids given as arguments
         * and count the number of sets
         */
        count_sets: function(indexes) {
            var idx = _.compact(indexes);
            var l = idx.length;
            if (l < 3) {
                return 0;
            }

            var sets = 0;
            for (var i = 0; i <= l - 3; i++) {
                for (var j = i + 1; j <= l - 2; j++) {
                    for (var k = j + 1; k <= l - 1; k++) {
                        if (this.is_set(idx[i], idx[j], idx[k])) {
                            sets += 1;
                        }
                    }
                }
            }
            return sets;
        },

        /**
         * Internal method, takes 3 card models and returns
         * bool if set or not
         */
        _is_card_set: function(c1, c2, c3) {
            return _.all(['num', 'fill', 'color', 'shape'], function(attr) {
                return ((
                    // either all attributes are the same...
                    c1.get(attr) == c2.get(attr) &&
                    c2.get(attr) == c3.get(attr)
                ) || (
                    // or they're all different...
                    c1.get(attr) != c2.get(attr) &&
                    c2.get(attr) != c3.get(attr) &&
                    c1.get(attr) != c3.get(attr)
                ));
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
