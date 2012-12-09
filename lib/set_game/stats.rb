require 'redis/counter'

module SetGame
  class Stats

    NUM_GAMES   = Redis::Counter.new('stats:num_games')
    NUM_PLAYERS = Redis::Counter.new('stats:num_players')

    class << self

      def num_games
        NUM_GAMES.value
      end

      def increment_num_games
        NUM_GAMES.increment
      end

      def num_players
        NUM_PLAYERS.value
      end

      def increment_num_players
        NUM_PLAYERS.increment
      end

    end
  end
end
