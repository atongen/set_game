set  :branch,    'origin/master'
set  :rack_env, 'production'
set  :deploy_to, '/var/www/#{application}'
server "my-server.com", :app, :web, :db, :primary => true
