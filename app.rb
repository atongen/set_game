$:.unshift(File.expand_path("../lib", __FILE__))

require 'rt'

require 'sinatra'
require 'sinatra-websocket'

set :server, 'thin'

enable :sessions

GAMES = {}

helpers do
  def get_player
    unless @player
      if session[:player_id]
        @player = Rt::Player.find_by_id(session[:player_id])
        @player.name = "wow"
        @placer.score = 0
      else
        @player = Rt::Player.new
        session[:player_id] = @player.id
      end
    end
    @player
  end
end

get '/' do
  erb :index
  get_player
end

post '/' do
  game = Rt::Game.new
  GAMES[game.id] = game
  redirect to("/#{game.id}")
end

get '/:id' do
  get_player
  if GAMES.has_key?(params[:id])
    if request.websocket?
      game = GAMES[params[:id]]
      request.websocket do |ws|
        ws.onopen do
          player = game.add_player(@player, ws)
          game.announce(Rt::Msg.say("#{player.name} joined game."))
        end
        ws.onmessage do |msg|
          EM.next_tick do
            game.handle(ws, Rt::Msg.parse(msg))
          end
        end
        ws.onclose do
          game.remove_player(ws)
          game.announce(Rt::Msg.say("#{@player.name} left game."))
        end
      end
    else
      @game = GAMES[params[:id]]
      erb :show
    end
  else
    redirect to('/')
  end
end
