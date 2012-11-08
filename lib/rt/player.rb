module Rt
  class Player
    include Model
    value :name
    attr_accessor :games

    def initialize(id = nil)
      super
      if self.name.value.to_s.strip == ""
        self.name.value = "Player ##{@id}"
      end
      self.games = {}
    end

    def announce(msg)
      games.keys.each { |ws| ws.send(msg) }
    end

    def add_game(ws, game)
      self.games[ws] = game
    end

    def remove_game(ws)
      self.games.delete(ws)
    end
  end
end
