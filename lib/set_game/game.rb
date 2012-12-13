module SetGame
  class Game
    include Model

    # States:
    # new
    # waiting
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
    set :ready_player_ids

    # players by ws tracks active web socket connections
    attr_accessor :players_by_ws

    # players by id tracks all players who have ever been in the game
    attr_accessor :players_by_id

    BOARD_SIZE = 12
    TIMEOUT = 60*60*24

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
            # player is ready to start game
            if new_game? && data['state'] == 'started'
              ready_player_ids << player.id
              not_ready = players_by_ws.values.map(&:id).map(&:to_i) - ready_player_ids.members.map(&:to_i)
              if not_ready.blank?
                @lock.synchronize do
                  # all connected players are ready to start game
                  state.value = 'started'
                  broadcast(:update_game, {
                    'cards_remaining' => cards_remaining,
                    'state' => state.value
                  })
                  broadcast(:update_board, board.map(&:to_s).join(":"))
                  broadcast(:update_score_box, score_box_data)
                  announce(name.value, "The game has started!")
                end
              else
                announce(name.value, "#{player.name.value} is ready to start.")
                ws.send(Msg.update_game({ 'state' => 'waiting' }))
              end
            end
            if started? && data['state'] == 'stalled'
              @lock.synchronize do
                stalled_player_ids << player.id
                not_stalled = players_by_ws.values.map(&:id).map(&:to_i) - stalled_player_ids.members.map(&:to_i)
                if not_stalled.blank? || sets_on_board == 0
                  replace = []
                  while replace.length < 3
                    idx = rand(12)
                    if board[idx].present? && !replace.include?(idx)
                      replace << idx
                    end
                  end
                  replace.each do |ridx|
                    if new_id = deck.pop
                      old_id = board[ridx]
                      board[ridx] = new_id
                      deck.unshift(old_id)
                    end
                  end
                  broadcast(:update_board, board.map(&:to_s).join(":"))
                  announce(name.value, "Board randomly updated")
                  broadcast(:update_game, {
                    'state' => 'started',
                    'cards_remaining' => cards_remaining
                  })
                  while stalled_player_ids.pop; end
                else
                  announce(name.value, "#{player.name.value} has stalled out!")
                  ws.send(Msg.update_game({ 'state' => 'stalled' }))
                end
                broadcast(:update_score_box, score_box_data)
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

    def handle_move(player_id, idx1, id1, idx2, id2, idx3, id3)
      if player = players_by_id[player_id]
        @lock.synchronize do
          if board[idx1].to_i == id1 &&
             board[idx2].to_i == id2 &&
             board[idx3].to_i == id3
            # It's a valid move
            if Card.set_index?(id1, id2, id3)
              # It's a set!
              [idx1, idx2, idx3].each { |pos| board[pos] = deck.pop }
              increment_score(player.id)
              player.num_scores.increment

              # empty stalled_player_ids after set is achived
              while stalled_player_ids.pop; end

              announce(name.value, "#{player.name.value} got a set!")
              broadcast(:update_board, board.map(&:to_s).join(":"))
              broadcast(:update_score_box, score_box_data)

              if game_over?
                # the game is over
                state.value = 'complete'

                # declare the winner(s)
                sbx = score_box_data
                winning_score = sbx.first['score']
                winners = sbx.select { |s| s['score'] == winning_score }
                if winners.length == 1
                  announce(name.value, winners.first['name'] + ' won the game!')
                else
                  announce(name.value, winners.map { |w| w['name'] }.join(' and ') + ' tied for the win!')
                end
              end
              # always update game state
              broadcast(:update_game, {
                'state' => state.value,
                'cards_remaining' => cards_remaining
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

      if !completed?
        if self.player_ids.include?(player.id)
          announce(name.value, "#{player.name.value} returned")
        else
          self.player_ids << player.id
          player.num_games.increment
          increment_score(player.id, 0)
          announce(name.value, "#{player.name.value} joined game")
        end
      end

      ws.send(Msg.update_game({ 'state' => state.value, 'creator_id' => creator_id.value.to_i }))
      # lock so we can send initial board state to added player
      @lock.synchronize do
        unless new_game?
          ws.send Msg.update_board(board.map(&:to_s).join(":"))
        end
        broadcast(:update_score_box, score_box_data)
      end

      player
    end

    def remove_player(ws)
      if player = players_by_ws.delete(ws)
        if !completed?
          announce(name.value, "#{player.name.value} left game")
          @lock.synchronize { broadcast(:update_score_box, score_box_data) }
        end
        ws
      end
    end

    def invite(to_email, from_name, msg = nil)
      $emailer.invite(self.id, to_email, from_name, msg)
    end

    def sets_on_board
      Card.count_sets(board.map { |b| b.present? ? b.to_i : nil })
    end

    def cards_remaining
      board.select { |b| b.present? }.length + deck.length
    end

    def game_over?
      !Card.set_exists?((board.values + deck.values).select(&:present?).map(&:to_i))
    end

    def new_game?
      state.value == 'new'
    end

    def started?
      state.value == 'started'
    end

    def waiting?
      state.value == 'waiting'
    end

    def completed?
      state.value == 'completed'
    end

    def destroy!
      %w{ state
          last_activity_at
          password
          name
          deck
          board
          player_ids
          comments
          scores
          creator_id
          stalled_player_ids
          ready_player_ids }.map do |obj_name|
        key_name = self.send(obj_name.to_sym).key
        $redis.del(key_name)
        key_name
      end
    end

    def can_be_destroyed?
      completed? && players_by_ws.blank? ||
        (Time.now.to_i - last_activity_at.value.to_i) > TIMEOUT
    end

    private

    def touch
      self.last_activity_at = Time.now.to_i
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
        { 'id'     => id,
          'name'   => player.name.value,
          'score'  => (scores[player.id] || '0').to_i,
          'status' => status
        }
      end
      # sort by score first, and name second
      data.sort { |x,y| [y[2], x[1]] <=> [x[2], y[1]] }
    end
  end
end
