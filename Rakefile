require 'fileutils'
require 'pathname'
require 'rake/testtask'
require 'yard'

SET_GAME_ROOT = Pathname.new(File.expand_path('..', __FILE__))

task :environment do
  require SET_GAME_ROOT.join("lib", "set_game")
end

desc "Clean JS"
task :clean_js do
  built = SET_GAME_ROOT.join('public', 'assets', 'js', 'main-built.js')
  FileUtils.rm(built) if File.file?(built)
end

desc "Compile JS"
task :compile_js => :clean_js do
  if %x{ which node }.to_s.strip == ''
    raise "node must be in path"
  end
  js_dir = SET_GAME_ROOT.join('public', 'assets', 'js')
  puts %x{ cd "#{js_dir}" && node ../../../bin/r.js -o app.build.js 2>&1 }
end

Rake::TestTask.new(:spec) do |t|
  t.libs << 'lib'
  t.libs << 'spec'
  t.pattern = 'spec/**/*_spec.rb'
  t.verbose = true
end

YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb']
end
