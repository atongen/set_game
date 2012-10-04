module Rt
  module Msg
    class << self

      def say(msg)
        build('say', { 'msg' => msg })
      end

      def method_missing(sym, *args, &block)
        { 'type' => sym, 'data' => args[0]}.to_json
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
