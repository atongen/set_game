require 'fileutils'
require 'pathname'
#require 'rake/testtask'
#require 'yard'

SET_GAME_ROOT = Pathname.new(File.expand_path('..', __FILE__))

task :environment do
  require SET_GAME_ROOT.join("lib", "set_game")
end

namespace :assets do

  desc "Clean JS"
  task :clean_js do
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
  task :clean_css do
    built_css = SET_GAME_ROOT.join('public', 'assets', 'css', 'app-built.css')
    FileUtils.rm(built_css) if File.file?(built_css)
  end

  desc "Compile CSS"
  task :compile_css => :clean_css do
    require 'yui/compressor'
    require 'stringio'

    css = %w{
      bootstrap.css
      app.css
    }

    compressor = YUI::CssCompressor.new
    src = ""
    StringIO.open(src, 'w') do |io|
      css.each do |f|
        io.puts File.read(SET_GAME_ROOT.join('public', 'assets', 'css', f))
      end
    end
    File.open(SET_GAME_ROOT.join('public', 'assets', 'css', 'app-built.css'), 'w') do |dst|
      dst << compressor.compress(src)
    end
  end

  desc "Precompile Assets"
  task :precompile => [:compile_css, :compile_js]
end

#Rake::TestTask.new(:spec) do |t|
#  t.libs << 'lib'
#  t.libs << 'spec'
#  t.pattern = 'spec/**/*_spec.rb'
#  t.verbose = true
#end

#YARD::Rake::YardocTask.new do |t|
#  t.files = ['lib/**/*.rb']
#end
