require 'pathname'
SET_GAME_ROOT = Pathname.new(File.expand_path('../..', __FILE__))
$:.unshift(SET_GAME_ROOT.join('lib'))

require 'yaml'
require 'figaro'
require 'set_game'
