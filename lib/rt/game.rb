module Rt
  class Game
    include Model

    value :password
    set :player_ids

    DECK_SIZE = 12
    attr_reader :deck, :board, :players

    def initialize
      super
      self.password = SecureRandom.hex(2)
      @deck = Card.deck.shuffle
      @board = @deck.pop(DECK_SIZE)
      @players = {}
    end

    def handle(ws, msg)
      case msg['type']
      when 'say'
        announce(Msg.say("#{players[ws].name} says '#{msg['data']['msg']}'"))
      when 'play'

      end
    end

    def announce(msg)
      players.keys.each { |ws| ws.send(msg) }
    end

    def add_player(player, ws)
      player_ids << player.id
      players[ws] = player
    end

    def remove_player(ws)
      players.delete(ws)
    end
  end
end
