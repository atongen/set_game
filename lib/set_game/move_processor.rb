module SetGame
  class MoveProcessor
    include Celluloid

    def process
      begin
        queue, msg = $redis.brpop(["game-moves"], 0)

        if msg
          args = msg.split(":").map(&:to_i)
          game_id = args.first
          if game = GAMES[game_id]
            player_id = args[1]
            game.handle_move(player_id, *args[2..-1])
          end
        end

        after(0) { trigger_process }
      rescue => e
        puts e.inspect
        after(1) { trigger_process }
      end
    end

    private

    def trigger_process
      Celluloid::Actor[:move_processor_pool].process!
    end
  end
end
