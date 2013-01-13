GAMES = {}
PLAYERS = {}

require File.expand_path("../config/environment", __FILE__)

SetGame::MoveProcessorGroup.run!
Celluloid::Actor[:move_processor_pool].process!

require 'sinatra'
require 'sinatra-websocket'
require 'rack-flash'

set :server, 'thin'
enable :sessions
set :protection, :except => :session_hijacking
use Rack::Flash, :sweep => true

helpers do
  def get_player
    if session[:player_id]
      if PLAYERS.has_key?(session[:player_id].to_i)
        PLAYERS[session[:player_id].to_i]
      else
        PLAYERS[session[:player_id].to_i] = SetGame::Player.find(session[:player_id].to_i)
      end
    else
      player = SetGame::Player.new
      SetGame::Stats.increment_num_players
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

  def clean_up
    # remove old games
    games_to_rm = []
    GAMES.each do |id, game|
      games_to_rm << id if game.can_be_destroyed?
    end
    games_to_rm.each do |id|
      game = GAMES[id]
      game.destroy!
      GAMES.delete(id)
    end

    # remove players who are gone
    players_to_rm = []
    PLAYERS.each do |id, player|
      players_to_rm << id if player.games.blank?
    end
    players_to_rm.each do |id|
      PLAYERS.delete(id)
    end

    true
  end

  def random_card_numbers(n)
    r = []
    while r.length < n
      r |= [rand(81)]
    end
    r.map { |c| c.to_s.rjust(2, '0') }
  end
end

get '/' do
  get_player
  erb :index
end

post '/games' do
  clean_up
  if GAMES.length < CONFIG['max_games']
    game = SetGame::Game.new
    GAMES[game.id] = game
    player = get_player
    game.player_ids << player.id
    game.creator_id.value = player.id
    SetGame::Stats.increment_num_games
    redirect to("/games/#{game.id}")
  else
    flash[:notice] = 'There are too many games being played right now! Please try again later.'
    redirect to('/')
  end
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
        if game.player_ids.include?(player.id) && game.players_by_ws.length < CONFIG['max_players_per_game']
          player.add_game(ws, game)
          game.add_player(ws, player)
        end
      end
      ws.onmessage do |msg|
        if game.players_by_id.include?(player.id)
          EM.next_tick do
            game.handle(ws, msg)
          end
        end
      end
      ws.onclose do
        game.remove_player(ws)
        player.remove_game(ws)
        clean_up
      end
    end
  else
    flash[:notice] = "The game isn't there!"
    redirect to('/')
  end
end

get '/games/:id/login' do
  if (@game = get_game) && (@player = get_player)
    erb :login
  else
    flash[:notice] = "The game isn't there!"
    redirect to('/')
  end
end

post '/games/:id/login' do
  if (@game = get_game) && (@player = get_player)
    if @game.password.value == params[:password]
      @game.player_ids << @player.id
      if @game.players_by_ws.length < CONFIG['max_players_per_game']
        redirect to("/games/#{@game.id}")
      else
        flash[:notice] = "There are too many players in that game already!"
        redirect to('/')
      end
    else
      flash[:notice] = "Invalid password for this game."
      erb :login
    end
  else
    flash[:notice] = "The game isn't there!"
    redirect to('/')
  end
end
