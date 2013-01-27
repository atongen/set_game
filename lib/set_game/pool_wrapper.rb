require 'set_game/redis_connection'

module SetGame
  class PoolWrapper

    attr_reader :redis

    def initialize
      @redis = RedisConnection.create({
        'host'      => ENV['REDIS_HOST'].present? ? ENV['REDIS_HOST'] : nil,
        'port'      => ENV['REDIS_PORT'].present? ? ENV['REDIS_PORT'].to_i : nil,
        'database'  => ENV['REDIS_DATABASE'].present? ? ENV['REDIS_DATABASE'].to_i : nil,
        'driver'    => ENV['REDIS_DRIVER'].present? ? ENV['REDIS_DRIVER'] : nil,
        'size'      => ENV['REDIS_SIZE'].present? ? ENV['REDIS_SIZE'].to_i : nil,
        'namespace' => ENV['REDIS_NAMESPACE'].present? ? ENV['REDIS_NAMESPACE'] : nil
      })
    end

    def method_missing(sym, *args, &block)
      redis.with do |conn|
        conn.send(sym, *args, &block)
      end
    end
  end
end
