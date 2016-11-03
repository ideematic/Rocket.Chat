server 'ks392825.kimsufi.com', user: 'rails', roles: %w{app web db}, primary: true

set :stage, 'production'

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/rails/www/#{fetch(:application)}_#{fetch(:rails_env)}"
set :branch, 'production'
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:rails_env)}" }
