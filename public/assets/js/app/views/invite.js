define([
    'jquery',
    'underscore',
    'backbone',
    'lib/Modal',
    'app/models/invite'
],

function(
    $,
    _,
    Backbone,
    Modal,
    Invite
) {

    return Backbone.View.extend({

        events: {
            'click #invite-btn': 'trigger_invite_modal'
        },

        initialize: function() {
            _.bindAll(this);

            /**
             * Setup modal
             */
            this.modal = new Modal({
                id: 'invite-modal',
                title: 'Invite a Friend',
                body: "<input type='text' id='to-email-field' val='' placeholder='Recipient email...'/><br />" +
                      "<input type='text' id='from-name-field' val='' placeholder='Your name...'/>",
                context: this,
                submit: function(content) {
                    this.send_invite(content);
                }
            });
        },

        render: function() {
            return this;
        },

        trigger_invite_modal: function(e) {
            e.preventDefault();
            this.modal.render();
        },

        send_invite: function(content) {
            var to_email = content.find('input#to-email-field').val();
            var from_name = content.find('input#from-name-field').val();
            if ($.trim(to_email) != "" && $.trim(from_name) != "") {
                var invt = new Invite();
                invt.set({ to_email: to_email, from_name: from_name });
                invt.save();
                this.modal.close();
            }
        }

    });

});
