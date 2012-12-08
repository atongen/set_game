module Rt
  class MoveProcessorGroup < Celluloid::SupervisionGroup
    SIZE = 4
    pool MoveProcessor, :as => :move_processor_pool, :size => SIZE
  end
end
