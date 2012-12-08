require 'pathname'
SET_GAME_ROOT = Pathname.new(File.expand_path('../..', __FILE__))
$:.unshift(SET_GAME_ROOT.join('lib'))

require 'json'
require 'time'
require 'yaml'
require 'thread'
require 'celluloid'

require 'active_support/lazy_load_hooks'
require 'active_support/core_ext/string'

config_path = SET_GAME_ROOT.join('config', 'set_game.yml')
if File.file?(config_path)
  CONFIG = YAML::load(File.read(config_path)) || {}
else
  CONFIG = {}
end

module SetGame
  autoload :Model,              "set_game/model"
  autoload :Msg,                "set_game/msg"
  autoload :Game,               "set_game/game"
  autoload :Player,             "set_game/player"
  autoload :Card,               "set_game/card"
  autoload :MoveProcessor,      "set_game/move_processor"
  autoload :MoveProcessorGroup, "set_game/move_processor_group"
  autoload :PoolWrapper,        "set_game/pool_wrapper"
  autoload :Inviter,            "set_game/inviter"
end

$redis = SetGame::PoolWrapper.new
$inviter = SetGame::Inviter.new
