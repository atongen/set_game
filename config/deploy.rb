set :stages, %w{ production }
set :default_stage, 'production'

require 'capistrano/ext/multistage'
require "bundler/capistrano"

set :scm_username do
  Capistrano::CLI.ui.ask "Which scm user should be used?" do |q|
    q.default = %x{ whoami }.strip
  end
end

set :application, "set_game"
set :scm, "git"
set :repository, "git@github.com:#{scm_username}/#{application}.git"

namespace :deploy do
  desc "Deploy the MFer"
  task :default do
    update
    restart
    cleanup
  end
 
  desc "Setup a GitHub-style deployment."
  task :setup, :except => { :no_release => true } do
    run "git clone #{repository} #{current_path}"
  end
 
  desc "Update the deployed code."
  task :update_code, :except => { :no_release => true } do
    run "cd #{current_path}; git fetch origin; git reset --hard #{branch}"
  end
 
  desc "Rollback a single commit."
  task :rollback, :except => { :no_release => true } do
    set :branch, "HEAD^"
    default
  end
end

set :normal_symlinks, %w(
  config/application.yml
)
 
set :weird_symlinks, {
}
 
namespace :symlinks do
  desc "Make all the damn symlinks"
  task :make, :roles => :app, :except => { :no_release => true } do
    commands = normal_symlinks.map do |path|
      "rm -rf #{release_path}/#{path} && \
       ln -s #{shared_path}/#{path} #{release_path}/#{path}"
    end
 
    commands += weird_symlinks.map do |from, to|
      "rm -rf #{release_path}/#{to} && \
       ln -s #{shared_path}/#{from} #{release_path}/#{to}"
    end
 
    # needed for some of the symlinks
    run "mkdir -p #{current_path}/tmp"
 
    run <<-CMD
      cd #{release_path} &&
      #{commands.join(" && ")}
    CMD
  end
end
 
after "deploy:update_code", "symlinks:make"
