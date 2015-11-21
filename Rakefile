require 'fileutils'
require 'pathname'
#require 'rake/testtask'
#require 'yard'

task :environment do
  require File.expand_path('../config/environment', __FILE__)
end

namespace :assets do
  desc "Clean JS"
  task :clean_js => :environment do
    built_js = SET_GAME_ROOT.join('public', 'assets', 'js', 'main-built.js')
    FileUtils.rm(built_js) if File.file?(built_js)
  end

  desc "Compile JS"
  task :compile_js => :clean_js do
    if %x{ which node }.to_s.strip == ''
      raise "node must be in path"
    end
    js_dir = SET_GAME_ROOT.join('public', 'assets', 'js')
    puts %x{ cd "#{js_dir}" && node ../../../bin/r.js -o app.build.js 2>&1 }
  end

  desc "Clean CSS"
  task :clean_css => :environment do
    built_css = SET_GAME_ROOT.join('public', 'assets', 'css', 'app-built.css')
    FileUtils.rm(built_css) if File.file?(built_css)
  end

  desc "Compile CSS"
  task :compile_css => :clean_css do
    require 'sass'

    css = %w{
      bootstrap.css
      app.css
    }.map { |f| SET_GAME_ROOT.join('public/assets/css', f) }

    cat = SET_GAME_ROOT.join('public/assets/css/app-cat.css')
    `cat #{css.join(' ')} > #{cat}`

    built = SET_GAME_ROOT.join('public/assets/css/app-built.css')
    `sass -t compressed #{cat} #{built}`
  end

  desc "Precompile Assets"
  task :precompile => [:compile_css, :compile_js]
end
