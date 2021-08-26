# config valid for current version and patch releases of Capistrano
lock "~> 3.16.0"

# Это имя приложения
set :application, 'photo'

# Это url вашего репозитория, откуда Capistrano будет брать свежие версии исходников
set :repo_url, 'git@github.com:dmentry/site_rails.git'

# Папка, где будет храниться приложение
set :deploy_to, '/home/deploy/www/photo'

# Файлы, которые лежат вне репозитория
append :linked_files, 'config/master.key'
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads'

Rake::Task["deploy:assets:backup_manifest"].clear_actions

# Копировать папку blog рекурсивно на сервер
namespace :blog do
  desc 'Blog photos copy'
  task :copy do
    run_locally do
      execute "scp -r /home/dmitry/RoR/Apps/site_rails/public/blog deploy@185.12.127.17:/home/deploy/www/photo/current/public/"
    end
  end
end

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
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
