module Rt
  class Player
    include Model
    value :name
    value :score

    #def initialize(name = nil)
      #super(nil)
    #  self.name = name  || "Player ##{id}"
    #  self.score = 0
    #end
  end
end
