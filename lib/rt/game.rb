module Rt
  class Game

    attr_reader :id, :players

    def initialize
      @id = Time.now.to_i.to_s
      @deck = Card.deck.shuffle
      @players = {}
    end

    def handle(ws, msg)
      case msg['type']
      when 'say'
        announce(Msg.say("#{players[ws].name} says '#{msg['data']['msg']}'"))
      end
    end

    def announce(msg)
      players.keys.each { |ws| ws.send(msg) }
    end

    def add_player(ws)
      n = players.length + 1
      players[ws] = Player.new("Player ##{n}")
    end

    def remove_player(ws)
      players.delete(ws)
    end
  end
end
