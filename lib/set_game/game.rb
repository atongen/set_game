module SetGame
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
    hash_key :scores
    value :creator_id
    set :stalled_player_ids

    # players by ws tracks active web socket connections
    attr_accessor :players_by_ws

    # players by id tracks all players who have ever been in the game
    attr_accessor :players_by_id

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

      self.players_by_ws = {}
      self.players_by_id = player_ids.inject({}) do |players, id|
        if p = SetGame::Player.find(id.to_i)
          players[p.id.to_i] = p
        end
        players
      end

      @lock = Mutex.new
      touch
    end

    def handle(ws, msg)
      touch
      begin
        if player = players_by_ws[ws]
          type, data = Msg.parse(msg).values_at('type', 'data')
          case type
          when 'create_comment'
            announce(player.name.value, data['content'])
          when 'create_move'
            $redis.lpush "game-moves", "#{id}:#{player.id}:" + data['spec']
          when 'update_player'
            if data['name'].present? && data['name'] != player.name.value
              old_name = player.name.value
              new_name = data['name']
              player.name.value = new_name
              player.announce(name.value, "#{old_name} is now known as #{new_name}")
              player.broadcast(:update_player, { 'name' => new_name })
            end
          when 'update_game'
            # only creator can update game
            if player.id == creator_id.value.to_i
              if data['name'].present? && data['name'] != name.value
                new_name = data['name']
                name.value = new_name
                announce(name.value, "The game has been renamed #{new_name}")
                broadcast(:update_game, { 'name' => new_name })
              end
            end
          else
            puts "Unknown message: #{msg.inspect}"
          end
        else
          puts "Player web socket connection not found"
        end
      rescue => e
        puts "Error processing message: #{e.inspect}"
      end
    end

    def announce(author, content)
      comment = {
        'author' => author,
        'content' => content,
        'created_at' => Time.now.to_i
      }
      self.comments << comment.to_json
      broadcast(:read_comments, comment)
    end

    def broadcast(key, data)
      obj = Msg.send(key, data)
      players_by_ws.keys.each { |ws| ws.send(obj) }
    end

    def handle_move(player_id, pos1, card1, pos2, card2, pos3, card3)
      if player = players_by_id[player_id]
        @lock.synchronize do
          if board[pos1].to_i == card1 &&
             board[pos2].to_i == card2 &&
             board[pos3].to_i == card3
            # It's a valid move
            if Card.set_index?(card1, card2, card3)
              # It's a set!
              [pos1, pos2, pos3].each { |pos| board[pos] = deck.pop }
              increment_score(player.id)

              announce self.name.value, "#{player.name.value} got a set!"
              broadcast(:update_board, board.map(&:to_s).join(":"))
              broadcast(:update_score_box, score_box_data)
              broadcast(:update_game, {
                'name' => name.value,
                'cards_remaining' => cards_remaining,
              })
            end
          end
        end
      end
    end

    def add_player(ws, player)
      self.players_by_ws[ws] = player
      self.players_by_id[player.id.to_i] = player

      # send comments to player
      ws.send(Msg.read_comments(comments.map { |c| JSON.parse(c) }))

      if self.player_ids.include?(player.id)
        announce(name.value, "#{player.name.value} returned")
      else
        self.player_ids << player.id
        increment_score(player.id, 0)
        announce(name.value, "#{player.name.value} joined game")
      end

      # lock so we can send initial board state to added player
      @lock.synchronize do
        ws.send Msg.update_board(board.map(&:to_s).join(":"))
        broadcast(:update_score_box, score_box_data)
      end

      player
    end

    def remove_player(ws)
      if player = players_by_ws.delete(ws)
        announce(name.value, "#{player.name.value} left game")
        @lock.synchronize { broadcast(:update_score_box, score_box_data) }
        ws
      end
    end

    def invite(to_email, from_name, msg = nil)
      $emailer.invite(self.id, to_email, from_name, msg)
    end

    def sets_on_board
      Card.count_sets(board.map(&:to_i))
    end

    def cards_remaining
      board.length + deck.length
    end

    private

    def touch
      self.last_activity_at = Time.now.to_f
    end

    def increment_score(player_id, n = 1)
      if scores[player_id].present?
        scores[player_id] = scores[player_id].to_i + n
      else
        scores[player_id] = n
      end
    end

    def score_box_data
      active_ids = players_by_ws.values.map(&:id)
      data = players_by_id.map do |id, player|
        # statuses correspond to twitter bootstrap badge styles
        # not ideal...
        status = if active_ids.include?(id)
          # connected player
          if stalled_player_ids.include?(id)
            # stalled player
            'warning'
          else
            # normal player
            'success'
          end
        else
          # disconnected player
          'important'
        end
        { :id     => id,
          :name   => player.name.value,
          :score  => (scores[player.id] || '0').to_i,
          :status => status
        }
      end
      # sort by score first, and name second
      data.sort { |x,y| [y[2], x[1]] <=> [x[2], y[1]] }
    end
  end
end
