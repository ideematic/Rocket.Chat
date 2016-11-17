server '62.210.93.225', user: 'rocketchat', roles: %w{app web db}, primary: true

set :stage, 'production'

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/rocketchat/www/#{fetch(:application)}_#{fetch(:stage)}"
set :branch, 'production'
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }
