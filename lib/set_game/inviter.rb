require 'pony'

module SetGame
  # TODO: Rename this: Emailer
  class Inviter
    include Celluloid

    def invite(game_id, to_email, from_name, msg = nil)
      mail = {
        :to => to_email,
        :from => CONFIG["smtp"]["user_name"],
        :subject => "#{from_name} is inviting you to play set!",
        :body => build_body(game_id, from_name, msg),
        :via => :smtp,
        :via_options => CONFIG["smtp"]
      }
      #puts mail.inspect
      Pony.mail(mail)
    end

    private

    def build_body(game_id, from_name, msg = nil)
      game = Game.find(game_id)
<<EOF
#{from_name} has invited you to play set in game named #{game.name.value}.
To join, go here: #{CONFIG['url']}/games/#{game.id}
The password is #{game.password.value}
EOF
    end
  end
end
