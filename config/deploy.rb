require 'capistrano/ext/multistage'
require "bundler/capistrano"

set :stages, %w{ production }
set :default_stage, 'production'

set :application, "set_game"
set :scm, "git"
set :repository, "git@mercury:#{application}.git"

set :thin_command, "bundle exec thin"
set :thin_config, "-C config/thin.yml"

default_run_options[:pty]   = true
default_run_options[:shell] = false
ssh_options[:forward_agent] = true

namespace :deploy do
  #task :default do
  #  update
  #  restart
  #  cleanup
  #end

  task :setup, :except => { :no_release => true } do
    run "git clone #{repository} #{current_path}"
  end

  task :update_code, :except => { :no_release => true } do
    run "cd #{current_path}; git fetch origin; git reset --hard #{branch}"
  end

  #task :rollback, :except => { :no_release => true } do
  #  set :branch, "HEAD^"
  #  default
  #end

  task :start do
    sudo "cd #{current_path} && #{thin_command} #{thin_config} start"
  end

  task :stop do
    sudo "cd #{current_path} && #{thin_command} #{thin_config} stop"
  end

  task :restart do
    sudo "cd #{current_path} && #{thin_command} #{thin_config} -O restart"
  end

  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      run "cd #{current_path} && bundle exec rake assets:precompile"
    end
  end
end

set :normal_symlinks, %w(
  config/application.yml
  config/thin.yml
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
