module Rt
  class Game
    include Model

    value :password
    #set :players
    list :deck
    list :board
    #list :comments, :marshal => true

    attr_accessor :web_sockets

    DECK_SIZE = 12

    def initialize
      super
      self.password = (rand(8999) + 1000).to_s
      (0...81).to_a.shuffle.each { |i| deck << i }
      DECK_SIZE.times { board << deck.pop }
      self.web_sockets = []
    end

    def handle(ws, msg)
      case msg['type']
      when 'say'
        announce(Msg.say("Player says '#{msg['data']['msg']}'"))
      when 'play'

      end
    end

    def announce(msg)
      web_sockets.each { |ws| ws.send(msg) }
    end

    def add_player(ws)
      #player_ids << player.id
      web_sockets << ws
    end

    def remove_player(ws)
      web_sockets.delete(ws)
    end
  end
end
