module Rt
  class Game
    include Model

    value :password
    list :deck
    list :board
    set :player_ids
    list :comments

    attr_accessor :players

    DECK_SIZE = 12

    def initialize(id = nil)
      super
      if !password
        self.password = (rand(8999) + 1000).to_s
      end
      if deck.length == 0
        (0...81).to_a.shuffle.each { |i| deck << i }
        DECK_SIZE.times { board << deck.pop }
      end
      self.players = {}
    end

    def handle(ws, msg)
      case msg['type']
      when 'say'
        announce(Msg.say("Player says '#{msg['data']['msg']}'"))
      when 'play'

      end
    end

    def announce(msg)
      players.keys.each { |ws| ws.send(msg) }
    end

    def add_player(ws, player)
      player_ids << player.id
      players[ws] = player
      announce("#{player.name} joined game")
      player
    end

    def remove_player(ws)
      player = players[ws]
      player_ids.delete(player.id)
      players.delete(player)
      announce("#{player.name} left game")
      ws
    end
  end
end
