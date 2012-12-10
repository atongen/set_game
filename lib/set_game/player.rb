module SetGame
  class Player
    include Model

    value :name
    counter :num_scores
    counter :num_games

    attr_accessor :games

    def initialize(id = nil)
      super
      if self.name.value.to_s.strip == ""
        self.name.value = "Player ##{@id}"
      end
      self.games = {}
    end

    def announce(author, msg)
      games.values.each { |game| game.announce(author, msg) }
    end

    def broadcast(key, data)
      obj = Msg.send(key, data)
      games.keys.each { |ws| ws.send(obj) }
    end

    def add_game(ws, game)
      self.games[ws] = game
    end

    def remove_game(ws)
      self.games.delete(ws)
    end
  end
end
