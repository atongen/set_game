GAMES = {}
PLAYERS = {}

require File.expand_path("../lib/set_game", __FILE__)

SetGame::MoveProcessorGroup.run!
Celluloid::Actor[:move_processor_pool].process!

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
        PLAYERS[session[:player_id]] = SetGame::Player.find(session[:player_id])
      end
    else
      player = SetGame::Player.new
      session[:player_id] = player.id
      PLAYERS[player.id] = player
    end
  end

  def get_game
    if params[:id]
      if GAMES.has_key?(params[:id].to_i)
        GAMES[params[:id].to_i]
      elsif game = SetGame::Game.find(params[:id].to_i)
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
  game = SetGame::Game.new
  GAMES[game.id] = game
  player = get_player
  game.player_ids << player.id
  game.creator_id.value = player.id
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
          game.handle(ws, msg)
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
