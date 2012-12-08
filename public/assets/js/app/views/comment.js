define([
    'jquery',
    'underscore',
    'backbone',
    'text!app/templates/comment.html'
],

function(
    $,
    _,
    Backbone,
    tpl
) {

    return Backbone.View.extend({

        tagName: 'li',
        className: 'comment',

        template: _.template(tpl),

        initialize: function() {
            this.$el.html(this.template({
                author: this.model.get('author'),
                created_at: this.model.timestamp(),
                content: this.model.get('content')
            }));
        },

        render: function() {
            return this;
        }
    });
});
