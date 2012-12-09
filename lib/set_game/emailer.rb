require 'pony'

module SetGame
  class Emailer
    include Celluloid

    def invite(game_id, to_email, from_name, msg = nil)
      send_email!(
        to_email,
        "#{from_name} is inviting you to play set!",
        invite_body(game_id, from_name, msg))
    end

    private

    def invite_body(game_id, from_name, msg = nil)
      game = Game.find(game_id)
<<EOF
#{from_name} has invited you to play set in game named #{game.name.value}.
To join, go here: #{CONFIG['url']}/games/#{game.id}
The password is #{game.password.value}
EOF
    end

    def send_email(to, subject, body)
      mail = {
        :to => to,
        :from => CONFIG["smtp"]["user_name"],
        :subject => subject,
        :body => body,
        :via => :smtp,
        :via_options => CONFIG["smtp"]
      }
      #puts mail.inspect
      Pony.mail(mail)
    end
  end
end
