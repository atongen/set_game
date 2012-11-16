require 'json'
require 'time'
require 'yaml'
require 'celluloid'
require 'rt/pool_wrapper'

require 'active_support/lazy_load_hooks'
#require 'active_support/all'
# move back to all if needed
require 'active_support/core_ext/string'

$redis = Rt::PoolWrapper.new

module Rt
  autoload :Model,           "rt/model"
  autoload :Msg,             "rt/msg"
  autoload :Game,            "rt/game"
  autoload :Player,          "rt/player"
  autoload :Card,            "rt/card"
  autoload :MoveProcessor,   "rt/move_processor"
end
