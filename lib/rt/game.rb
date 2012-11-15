module Rt
  class Game
    include Model

    # States:
    # new
    # started
    # complete
    value :state

    value :last_activity_at
    value :password
    list :deck
    list :board
    set :player_ids
    list :comments
    list :moves

    attr_accessor :players, :move_processor

    DECK_SIZE = 12

    def initialize(id = nil)
      puts caller.inspect
      puts 1
      super
      puts 2
      puts self.id
      if self.state.value.blank?
        puts 3
        self.password.value = (rand(8999) + 1000).to_s
        (0...81).to_a.shuffle.each { |i| deck << i }
        DECK_SIZE.times { board << deck.pop }
        self.state.value = 'new'
      end

      puts 4
      # ws can't be stored in redis...
      self.players = {}

      puts 5
      # process the game moves on a new thread
      self.move_processor = MoveProcessor.new(self.id)
      puts 6
      move_processor.async.process
      puts 7
    end

    def handle(ws, msg)
      player = players[ws]
      case msg['type']
      when 'say'
        announce("#{player.name.value} says '#{msg['data']['msg']}'")
      when 'move'
        self.moves << msg['data']
      #when 'start'
        # do starting here
      else
        puts "Unknown message: #{msg.inspect}"
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
