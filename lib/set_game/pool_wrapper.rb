require 'set_game/redis_connection'

module SetGame
  class PoolWrapper

    attr_reader :redis

    def initialize
      @redis = RedisConnection.create(CONFIG['redis'])
    end

    def method_missing(sym, *args, &block)
      redis.with do |conn|
        conn.send(sym, *args, &block)
      end
    end
  end
end
