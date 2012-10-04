$:.unshift(File.expand_path("../lib", __FILE__))

require 'rt'

require 'sinatra'
require 'sinatra-websocket'

set :server, 'thin'

GAMES = {}

get '/' do
  erb :index
end

post '/' do
  game = Rt::Game.new
  GAMES[game.id] = game
  redirect to("/#{game.id}")
end

get '/:id' do
  if GAMES.has_key?(params[:id])
    @game = GAMES[params[:id]]
    if request.websocket?
      request.websocket do |ws|
        ws.onopen do
          player = @game.add_player(ws)
          @game.announce(Rt::Msg.say("#{player.name} joined game."))
        end
        ws.onmessage do |msg|
          EM.next_tick do
            @game.handle(ws, Rt::Msg.parse(msg))
          end
        end
        ws.onclose do
          player = @game.remove_player(ws)
          @game.announce(Rt::Msg.say("#{player.name} left game."))
        end
      end
    else
      erb :show
    end
  else
    redirect to('/')
  end
end
