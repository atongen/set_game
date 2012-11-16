module Rt
  class MoveProcessor
    include Celluloid

    attr_accessor :game_id

    def initialize(game_id)
      @game_id = game_id
    end

    def process
      begin
        queue, msg = $redis.blpop(["game:#{game_id}:moves"], 0)

        if msg
          # let's process the next message!
          puts "game:#{game_id} msg = #{msg}"
        end

        after(0) { process }
      rescue => e
        puts e.inspect
        after(1) { process }
      end
    end
  end
end
