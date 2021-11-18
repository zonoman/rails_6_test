# cutte
# config valid for current version and patch releases of Capistrano
lock "~> 3.16"

set :application, "rails_6_test"
set :repo_url, "git@github.com:zonoman/rails_6_test.git"

set :rbenv_type, :system
set :rbenv_ruby, '3.0.0'
set :rbenv_prefix, "NODE_ENV=production RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/master.key", "config/database.yml", "config/settings.yml", "config/settings/production.yml", "config/settings/staging.yml", "app/javascript/stylesheets/tailwind.config.js"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "public/uploads"
set :assets_roles, %i[webpack] # Give the webpack role to a single server  
set :assets_prefix, 'packs' # Assets are located in /packs/
set :keep_assets, 10 # Automatically remove stale assets
set :assets_manifests, lambda { # Tell Capistrano-Rails how to find the Webpacker manifests
  [release_path.join('public', fetch(:assets_prefix), 'manifest.json*')]
}
# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 1

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

set :unicorn_pid, "#{shared_path}/tmp/pids/unicorn.pid"

after 'deploy:publishing', 'unicorn:restart'

before "deploy:assets:precompile", "deploy:yarn_install"
after "deploy:updated", "deploy:build"

namespace :deploy do
  desc "Run rake yarn install"
  task :yarn_install do
    on roles(:web) do
      within release_path do
        execute("cd #{release_path} && yarn install --silent --no-progress --no-audit --no-optional")
      end
    end
  end
  desc 'webpack build'
  task :build do
    on roles(:app) do
      within release_path do
        execute("cd #{release_path} && export NODE_ENV=production; bin/webpack")
      end
    end
  end
end
# This fixes a bundler version mismatch on the production server