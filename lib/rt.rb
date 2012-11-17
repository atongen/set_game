require 'json'
require 'time'
require 'yaml'
require 'celluloid'

require 'active_support/lazy_load_hooks'
require 'active_support/core_ext/string'

module Rt
  autoload :Model,              "rt/model"
  autoload :Msg,                "rt/msg"
  autoload :Game,               "rt/game"
  autoload :Player,             "rt/player"
  autoload :Card,               "rt/card"
  autoload :MoveProcessor,      "rt/move_processor"
  autoload :MoveProcessorGroup, "rt/move_processor_group"
  autoload :PoolWrapper,        "rt/pool_wrapper"
end

$redis = Rt::PoolWrapper.new
Rt::MoveProcessorGroup.run!
Celluloid::Actor[:move_processor_pool].process!

