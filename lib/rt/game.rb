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
    value :name
    list :deck
    list :board
    set :player_ids
    list :comments
    hash_key :player_scores

    attr_accessor :players

    BOARD_SIZE = 12

    def initialize(id = nil)
      super

      if self.state.value.blank?
        self.password.value = (rand(8999) + 1000).to_s
        (0...81).to_a.shuffle.each { |i| deck << i }
        BOARD_SIZE.times { board << deck.pop }
        self.state.value = 'new'
        self.name.value = "Game #{@id}"
      end

      # ws can't be stored in redis...
      self.players = {}
      @lock = Mutex.new
      touch
    end

    def handle(ws, msg)
      player = players[ws]
      data = msg['data']
      case msg['type']
      when 'say'
        announce("#{player.name.value} says '#{data}'")
      when 'move'
        $redis.lpush "game-moves", "#{id}:#{player.id}:" + data
      #when 'start'
        # do starting here
      else
        puts "Unknown message: #{msg.inspect}"
      end
    end

    def announce(msg)
      self.comments << msg
      broadcast(:say, msg)
    end

    def broadcast(key, data)
      obj = Msg.send(key, data)
      players.keys.each { |ws| ws.send(obj) }
    end

    def handle_move(player_id, pos1, card1, pos2, card2, pos3, card3)
      @lock.synchronize do
        if player = players.values.detect { |p| p.id == player_id }
          announce "#{player.name.value} moved: " + [pos1, card1, pos2, card2, pos3, card3].inspect
          announce [board[pos1], board[pos2], board[pos3]].inspect
          if board[pos1].to_i == card1 &&
             board[pos2].to_i == card2 &&
             board[pos3].to_i == card3
            # It's a valid move
            if Card.set_index?(card1, card2, card3)
              # It's a set!
              announce "#{player.name.value} got a set!"
              [pos1, pos2, pos3].each { |pos| board[pos] = deck.pop }
              player_scores[player.id] ||= 0
              player_scores[player.id] += 1
              broadcast(:board, board.map(&:to_s).join(":"))
            else
              # That wasn't a set!
              ws = players.key(player)
              ws.send(Msg.say("sorry"))
            end
          else
            # Invalid move
            announce "#{player.name.value} tried to cheat!"
          end
        end
      end
    end

    def add_player(ws, player)
      self.player_ids << player.id
      self.players[ws] = player
      @lock.synchronize { ws.send Msg.board(board.map(&:to_s).join(":")) }
      announce("#{player.name.value} joined game")
      player
    end

    def remove_player(ws)
      if player = players[ws]
        player_name = player.name
        player_ids.delete(player.id)
        players.delete(player)
        announce("#{player_name} left game")
        ws
      end
    end

    private

    def touch
      self.last_activity_at = Time.now.to_f
    end
  end
end
