require 'redis'
require 'redis/objects'
require 'json'
require 'time'

Redis.current = Redis.new

module Rt
  autoload :Model,  "rt/model"
  autoload :Msg,    "rt/msg"
  autoload :Game,   "rt/game"
  autoload :Player, "rt/player"
  autoload :Card,   "rt/card"
end
