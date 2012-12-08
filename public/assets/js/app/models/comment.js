define([
  'jquery',
  'underscore',
  'backbone',
  'lib/DateFormat'
],

function(
  $,
  _,
  Backbone,
  DateFormat
) {

  return Backbone.Model.extend({

    type: function() {
      return 'comment';
    },

    defaults: function() {
      return {
        author: null,
        created_at: null,
        content: null
      };
    },

    timestamp: function() {
        var d = new Date(0);
        d.setUTCSeconds(this.get('created_at'));
        console.log(DateFormat);
        return DateFormat.format(d, 'shortTime');
    }

  });

});
