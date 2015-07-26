require 'pathname'
SET_GAME_ROOT = Pathname.new(File.expand_path('../..', __FILE__))
$:.unshift(SET_GAME_ROOT.join('lib'))

require 'set_game/etcd'
require 'figaro'

if SetGame::Etcd.config_valid?
  SetGame::Etcd.read
end

require 'set_game'
