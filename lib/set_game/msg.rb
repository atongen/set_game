module SetGame
  module Msg
    class << self

      def method_missing(sym, *args, &block)
        if args.length == 1 && !block_given?
          build(sym, args[0])
        else
          super
        end
      end

      def parse(str)
        JSON.parse(str)
      end

      def build(type, data = nil)
        msg = { 'type' => type }
        msg['data'] = data if data
        msg.to_json
      end
    end
  end
end
