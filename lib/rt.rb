require 'redis'
require 'redis/objects'
require 'json'
require 'time'
require 'yaml'

config_path = RT_ROOT.join('config', 'rt.yml')
if File.file?(config_path)
  CONFIG = YAML.load(File.read(config_path))
else
  raise "Config missing."
end

Redis.current = Redis.new(CONFIG['redis'])

module Rt
  autoload :Model,  "rt/model"
  autoload :Msg,    "rt/msg"
  autoload :Game,   "rt/game"
  autoload :Player, "rt/player"
  autoload :Card,   "rt/card"
end
