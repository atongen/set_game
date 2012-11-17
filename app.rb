require 'pathname'
RT_ROOT = Pathname.new(File.expand_path('..', __FILE__))
$:.unshift(RT_ROOT.join('lib'))

GAMES = {}
PLAYERS = {}

require 'rt'
require 'sinatra'
require 'sinatra-websocket'

set :server, 'thin'
enable :sessions
set :protection, except: :session_hijacking

helpers do
  def get_player
    if session[:player_id]
      if PLAYERS.has_key?(session[:player_id])
        PLAYERS[session[:player_id]]
      else
        PLAYERS[session[:player_id]] = Rt::Player.find(session[:player_id])
      end
    else
      player = Rt::Player.new
      session[:player_id] = player.id
      PLAYERS[player.id] = player
    end
  end

  def get_game
    if params[:id]
      if GAMES.has_key?(params[:id].to_i)
        GAMES[params[:id].to_i]
      elsif game = Rt::Game.find(params[:id].to_i)
        GAMES[game.id] = game
      end
    end
  end
end

get '/' do
  get_player
  erb :index
end

post '/games' do
  game = Rt::Game.new
  GAMES[game.id] = game
  game.player_ids << get_player.id
  redirect to("/games/#{game.id}")
end

get '/games/:id' do
  if @game = get_game
    if (player = get_player) && (@game.player_ids.include?(player.id))
      @player = get_player
      erb :show
    else
      redirect to("/games/#{params[:id]}/login")
    end
  else
    redirect to('/')
  end
end

get '/games/:id/ws' do
  if request.websocket? && (game = get_game) && (player = get_player)
    request.websocket do |ws|
      ws.onopen do
        player.add_game(ws, game)
        game.add_player(ws, player)
      end
      ws.onmessage do |msg|
        EM.next_tick do
          game.handle(ws, Rt::Msg.parse(msg))
        end
      end
      ws.onclose do
        game.remove_player(ws)
        player.remove_game(ws)
      end
    end
  else
    redirect to('/')
  end
end

get '/games/:id/login' do
  @player = get_player
  @game = get_game
  erb :login
end

post '/games/:id/login' do
  if (@game = get_game) && (@player = get_player)
    if @game.password.value == params[:password]
      @game.player_ids << @player.id
      redirect to("/games/#{@game.id}")
    else
      erb :login
    end
  else
    redirect to('/')
  end
end
