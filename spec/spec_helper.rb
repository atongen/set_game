ENV["RACK_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)

require 'minitest/spec'
require 'minitest/autorun'

# Load support files
Dir[SET_GAME_ROOT.join("spec", "support", "**", "*.rb").to_s].each { |f| require f }
