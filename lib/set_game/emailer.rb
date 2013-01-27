require 'pony'

module SetGame
  class Emailer
    include Celluloid

    MAX_SHORT = 100
    MAX_LONG = 1000

    def invite(game_id, to_email, from_name, msg = nil)
      to_email = to_email.to_s.strip
      from_name = from_name.to_s.strip
      msg = msg.to_s.strip
      if valid_email?(to_email) && from_name.length < MAX_SHORT && msg.length < MAX_LONG
        send_email(
          to_email,
          "#{from_name} is inviting you to play set!",
          invite_body(game_id, from_name, msg))
      end
    end

    def message(game_id, player_id, from_name, from_email, msg)
      from_name = from_name.to_s.strip
      from_email = from_email.to_s.strip
      msg = msg.to_s.strip
      if valid_email?(from_email) && from_name.length < MAX_SHORT && msg.length < MAX_LONG
        send_email(
          ENV['MY_EMAIL'],
          "[SET GAME] Message",
          "\"#{from_name}\" <#{from_email}> says:\n\n#{msg}\n\nGame ID: #{game_id}\nPlayer ID: #{player_id}")
      end
    end

    private

    def send_email(to, subject, body)
      mail = {
        :to => to,
        :from => ENV['SMTP_USER_NAME'],
        :subject => subject,
        :body => body,
        :via => :smtp,
        :via_options => {
          :address              => ENV['SMTP_ADDRESS'],
          :port                 => ENV['SMTP_PORT'],
          :enable_starttls_auto => ENV['SMTP_ENABLE_STARTTLS_AUTO'],
          :user_name            => ENV['SMTP_USER_NAME'],
          :password             => ENV['SMTP_PASSWORD'],
          :authentication       => ENV['SMTP_AUTHENTICATION'],
          :domain               => ENV['SMTP_DOMAIN']
        }
      }
      Pony.mail(mail)
    end

    def invite_body(game_id, from_name, msg = nil)
      game = Game.find(game_id)
      body = <<EOF
#{from_name} has invited you to play the Set Game.
To join, go here: #{ENV['URL']}/games/#{game.id}
The password is #{game.password.value}
EOF
      if msg.present?
        body << "\n\n#{msg}"
      end
      body
    end

    def valid_email?(email)
      !!(/^(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})$/i).match(email)
    end

  end
end
