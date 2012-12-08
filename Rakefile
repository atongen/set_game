require 'fileutils'
require 'pathname'
SET_GAME_ROOT = Pathname.new(File.expand_path('..', __FILE__))

desc "Clean JS"
task :clean_js do
  built = RT_ROOT.join('public', 'assets', 'js', 'maint-built.js')
  FileUtils.rm(built) if File.file?(built)
end

desc "Compile JS"
task :compile_js => :clean_js do
  if %x{ which node }.to_s.strip == ''
    raise "node must be in path"
  end
  js_dir = RT_ROOT.join('public', 'assets', 'js')
  %x{ cd "#{js_dir}" && node ../../../bin/r.js -o app.build.js }
end