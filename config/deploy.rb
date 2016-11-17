# config valid only for current version of Capistrano
lock '3.6.1'

set :application, 'team_ideematic_com'

set :stages, %w(recipe production)
set :default_stage, "recipe"

set :scm, :git

set :project_release_id, `git log --pretty=format:'%h' -n 1 HEAD`
set :project_tarball_path, "#{Dir.pwd}/dist/Rocket.Chat.tar.gz"
set :project_tarball_path_remote, "/tmp/Rocket.Chat.tar.gz"
set :project_tarball_compiled_rocket_url, 'https://rocket.chat/releases/latest/download'
set :pty, true

append :linked_files, 'pm2.json'
set :pm2_config, 'pm2.json' # PM2 config path by default
set :keep_releases, 5

set :nvm_type, :user # or :system, depends on your nvm setup
set :nvm_node, 'v4.6.2'
set :nvm_map_bins, %w{node npm pm2}
set :linked_dirs, fetch(:linked_dirs, []).push('log')


module NoGitStrategy
  def check
    true
  end

  def test
    # Check if the tarball was uploaded.
    test! " [ -f #{fetch(:project_tarball_path_remote)} ] "
  end

  def clone
    true
  end

  def update
    true
  end

  def release
    # Unpack the tarball uploaded by deploy:upload_tarball task.
    context.execute "tar -C #{release_path} -zxf #{fetch(:project_tarball_path_remote)} bundle/ --strip-components=1"
    # Remove it just to keep things clean.
    context.execute :rm, fetch(:project_tarball_path_remote)
  end

  def fetch_revision
    # Return the tarball release id, we are using the git hash of HEAD.
    fetch(:project_release_id)
  end
end

set :git_strategy, NoGitStrategy

namespace :deploy do
  desc 'Create and upload project tarball'
  task :upload_tarball do |task, args|
    tarball_path = fetch(:project_tarball_path)
    # This will create a project tarball from HEAD, stashed and not committed changes wont be released.

    on roles(:all) do
      #upload! tarball_path, fetch(:project_tarball_path_remote)
      execute :wget, fetch(:project_tarball_compiled_rocket_url), '-O', fetch(:project_tarball_path_remote)
    end
  end
end

namespace :rocket_chat do
  desc "Build Rocket.Chat"

  task :build do
    on roles(:app) do
      within release_path do
        within "programs/server" do
          execute :npm, :install, raise_on_non_zero_exit: false
        end
      end
    end
  end
  task :run do
    on roles(:app) do
      within current_path do
        execute :pm2, :restart, fetch(:pm2_config)
      end
    end
  end
end

before 'deploy:updating', 'deploy:upload_tarball'
before 'deploy:publishing', 'rocket_chat:build'
after 'deploy:publishing', 'rocket_chat:run'
