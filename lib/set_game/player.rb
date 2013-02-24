module SetGame
  class Player
    include Model

    value :name
    value :joined_game
    counter :num_scores
    counter :num_games
    counter :num_wins

    attr_accessor :games

    def initialize(id = nil)
      super
      if self.name.value.to_s.strip == ""
        self.name.value = "Player ##{@id}"
      end
      if self.joined_game.to_s.strip == ""
        self.joined_game.value = "false"
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
      if !joined_game?
        SetGame::Stats.increment_num_players
        self.joined_game.value = "true"
      end
      self.games[ws] = game
    end

    def remove_game(ws)
      self.games.delete(ws)
    end

    def joined_game?
      self.joined_game.value == "true"
    end
  end
end
