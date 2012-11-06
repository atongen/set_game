module Rt
  class Player
    include Model
    value :name
    attr_accessor :games

    def initialize(id = nil)
      super
      self.name ||= "Player ##{id}"
    end

    def announce(msg)
      games.keys.each { |ws| ws.send(msg) }
    end

    def add_game(ws, game)
      games[ws] = game
      games
    end

    def remove_game(ws)
      games.delete(ws)
    end
  end
end
