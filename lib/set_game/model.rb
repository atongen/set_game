module SetGame
  module Model
    def self.included(klass)
      klass.class_eval do
        include Redis::Objects
        attr_reader :id
        counter :id_sequence, :global => true
      end

      klass.extend ClassMethods
    end

    module ClassMethods
      def find(id)
        new(id)
      end
    end

    def initialize(id = nil)
      if id
        @id = id
      else
        id_sequence.increment do |id_seq|
          @id = id_seq
        end
      end
    end
  end
end
