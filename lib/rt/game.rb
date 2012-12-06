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
    value :creator_id

    attr_accessor :players

    BOARD_SIZE = 12

    def initialize(id = nil)
      super

      if self.state.value.blank?
        self.password.value = (rand(8999) + 1000).to_s
        (0...81).to_a.shuffle.each { |i| deck << i }
        BOARD_SIZE.times { board << deck.pop }
        self.state.value = 'new'
        self.name.value = "Game ##{@id}"
      end

      # ws can't be stored in redis...
      self.players = {}
      @lock = Mutex.new
      touch
    end

    def handle(ws, msg)
      touch
      player = players[ws]
      type, data = Msg.parse(msg).values_at('type', 'data')
      case type
      when 'create_comment'
        announce(player.name.value, data['content'])
      when 'create_move'
        $redis.lpush "game-moves", "#{id}:#{player.id}:" + data['spec']
      when 'start'
        # do starting here
      when 'invite'
        invite(data, player.name.value)
      when 'rename_self'
        old_name = player.name.value
        player.name.value = data
        player.announce("#{old_name} is now known as '#{data}'")
        player.broadcast(:rename_self, data)
      when 'rename_game'
        self.name.value = data
        announce("The game has been renamed '#{data}'")
        broadcast(:rename_game, data)
      else
        puts "Unknown message: #{msg.inspect}"
      end
    end

    def announce(author, content)
      comment = {
        'author' => author,
        'content' => content,
        'created_at' => Time.now.to_s
      }
      self.comments << comment.to_json
      broadcast(:read_comments, comment)
    end

    def broadcast(key, data)
      obj = Msg.send(key, data)
      players.keys.each { |ws| ws.send(obj) }
    end

    def handle_move(player_id, pos1, card1, pos2, card2, pos3, card3)
      @lock.synchronize do
        if player = players.values.detect { |p| p.id == player_id }
          announce self.name.value, "#{player.name.value} moved: " + [pos1, card1, pos2, card2, pos3, card3].inspect
          announce self.name.value, [board[pos1], board[pos2], board[pos3]].inspect
          if board[pos1].to_i == card1 &&
             board[pos2].to_i == card2 &&
             board[pos3].to_i == card3
            # It's a valid move
            if Card.set_index?(card1, card2, card3)
              # It's a set!
              announce self.name.value, "#{player.name.value} got a set!"
              [pos1, pos2, pos3].each { |pos| board[pos] = deck.pop }
              #player_scores[player.id] ||= 0
              #player_scores[player.id] += 1
              broadcast(:board, board.map(&:to_s).join(":"))
            else
              # That wasn't a set!
              #ws = players.key(player)
              #ws.send(Msg.say("sorry"))
            end
          else
            # Invalid move
            announce self.name.value, "#{player.name.value} tried to cheat!"
          end
        end
      end
    end

    def add_player(ws, player)
      self.players[ws] = player
      if self.player_ids.include?(player.id)
        announce(name.value, "#{player.name.value} returned")
      else
        self.player_ids << player.id
        announce(name.value, "#{player.name.value} joined game")
      end
      # send comments to player
      ws.send(Msg.read_comments(comments.map { |c| JSON.parse(c) }))
      # send board to player
      send_board(ws)
      player
    end

    def remove_player(ws)
      if player = players[ws]
        player_name = player.name.value
        players.delete(player)
        announce(name.value, "#{player_name} left game")
        ws
      end
    end

    def invite(to_email, from_name, msg = nil)
      $inviter.invite!(self.id, to_email, from_name, msg)
    end

    private

    def send_board(ws)
      @lock.synchronize { ws.send Msg.board(board.map(&:to_s).join(":")) }
    end

    def touch
      self.last_activity_at = Time.now.to_f
    end
  end
end
