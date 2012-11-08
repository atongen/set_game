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
      if self.password.value.to_s.strip == ""
        self.password.value = (rand(8999) + 1000).to_s
      end
      if deck.length == 0
        (0...81).to_a.shuffle.each { |i| deck << i }
        DECK_SIZE.times { board << deck.pop }
      end
      self.players = {}
    end

    def handle(ws, msg)
      player = players[ws]
      case msg['type']
      when 'say'
        announce("#{player.name.value} says '#{msg['data']['msg']}'")
      when 'play'

      end
    end

    def announce(msg)
      self.comments << msg
      obj = Msg.say(msg)
      players.keys.each { |ws| ws.send(obj) }
    end

    def add_player(ws, player)
      self.player_ids << player.id
      self.players[ws] = player
      announce("#{player.name.value} joined game")
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
