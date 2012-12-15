require 'json'
require 'time'
require 'yaml'
require 'thread'
require 'celluloid'

require 'active_support/lazy_load_hooks'
require 'active_support/core_ext/string'

module SetGame
  autoload :Model,              "set_game/model"
  autoload :Msg,                "set_game/msg"
  autoload :Game,               "set_game/game"
  autoload :Player,             "set_game/player"
  autoload :Card,               "set_game/card"
  autoload :MoveProcessor,      "set_game/move_processor"
  autoload :MoveProcessorGroup, "set_game/move_processor_group"
  autoload :PoolWrapper,        "set_game/pool_wrapper"
  autoload :Emailer,            "set_game/emailer"
  autoload :Stats,              "set_game/stats"
end

$redis = SetGame::PoolWrapper.new
$emailer = SetGame::Emailer.new
