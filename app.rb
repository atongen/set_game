require 'redis'
require 'redis/objects'
require 'json'

Redis.current = Redis.new

module Model
  def self.included(klass)
    klass.class_eval do
      include Redis::Objects
      attr_reader :id
      counter :id_sequence, :global => true
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

class Thing 
  include Model
  list :data#, :maxlength => 10
end

require 'sinatra'
require 'sinatra-websocket'

set :server, 'thin'
set :sockets, []
set :thing, Thing.new(1)

get '/' do
  if request.websocket?
    request.websocket do |ws|
      ws.onopen do
        ws.send({ 'type' => "say", 'data' => { "msg" => "Hello World!"}}.to_json)
        settings.sockets << ws
      end
      ws.onmessage do |msg|
        EM.next_tick { settings.sockets.each{ |s| s.send({ 'type' => "say", 'data' => { 'msg' => msg }}.to_json) } }
      end
      ws.onclose do
        warn("wetbsocket closed")
        settings.sockets.delete(ws)
      end
    end
  else
    erb :index
  end
end

get '/hit/:val' do
  settings.thing.data << params[:val]
  l = settings.thing.data.length
  ave = settings.thing.data.inject(0) { |t,v| t += v.to_i }.to_f / l.to_f
  settings.sockets.each { |s| s.send({'type' => "say", 'data' => { 'msg' => "#{l}:#{ave}" }}.to_json) }
  ""
end
