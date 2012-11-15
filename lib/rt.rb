require 'redis'
require 'redis/objects'
require 'json'
require 'celluloid'
require 'time'
require 'yaml'

require 'active_support/lazy_load_hooks'
#require 'active_support/all'
# move back to all if needed
require 'active_support/core_ext/string'

config_path = RT_ROOT.join('config', 'rt.yml')

Redis.current = Redis.new(CONFIG['redis'])

module Rt
  autoload :Model,           "rt/model"
  autoload :Msg,             "rt/msg"
  autoload :Game,            "rt/game"
  autoload :Player,          "rt/player"
  autoload :Card,            "rt/card"
  autoload :MoveProcessor,   "rt/move_processor"
  autoload :RedisConnection, "rt/redis_connection"

  def self.redis(&block)
    @redis ||= RedisConnection.create
    raise ArgumentError, "requires a block" if !block
    @redis.with(&block)
  end
end
