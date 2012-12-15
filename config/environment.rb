ENV['RACK_ENV'] ||= 'development'

require 'pathname'
SET_GAME_ROOT = Pathname.new(File.expand_path('../..', __FILE__))

CONFIG = begin
  config_path = SET_GAME_ROOT.join('config', 'set_game.yml')
  YAML::load(File.read(config_path))[ENV['RACK_ENV']]
rescue
  {}
end

$:.unshift(SET_GAME_ROOT.join('lib'))
require 'set_game'
