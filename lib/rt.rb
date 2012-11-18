require 'pathname'
RT_ROOT = Pathname.new(File.expand_path('../..', __FILE__))
$:.unshift(RT_ROOT.join('lib'))

require 'json'
require 'time'
require 'yaml'
require 'thread'
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
