define([
    'jquery',
    'underscore',
    'backbone',
    'bootstrap',
    'text!lib/templates/modal.html'
],

function(
    $,
    _,
    Backbone,
    bootstrap,
    tpl
) {

    return Backbone.View.extend({

        el: '#modal',
        template: _.template(tpl),

        title: null,
        body: null,

        events: {
            'click .btn-primary': 'submit'
        },

        initialize: function(options) {
            _.bindAll(this);
            this.title = options.title;
            this.body = options.body;
            this.submit_fn = options.submit;
            this.close_fn = options.close;
            this.context = options.context;
        },

        render: function() {
            this.$el.html(this.template({
                id: this.id,
                title: this.title,
                body: this.body
            }));
            this.open();
            return this;
        },

        open: function() {
            this.inner_content().modal();
        },

        close: function() {
            this.inner_content().modal('hide');
        },

        submit: function() {
            if (_.isFunction(this.submit_fn)) {
                this.submit_fn.call(this.context, this.inner_content());
            }
        },

        inner_content: function() {
            return this.$el.find('#' + this.id);
        }
    });
});
