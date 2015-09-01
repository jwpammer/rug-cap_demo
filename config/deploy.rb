# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'rug-cap_demo'
set :repo_url, 'git@github.com:jwpammer/rug-cap_demo.git'

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "~/apps/#{fetch(:application)}"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :stats do
  task :uptime do
    on roles(:all), in: :parallel do |host|
      uptime = capture(:uptime)
      puts "#{host.hostname}:\n#{uptime}"
    end
  end

  task :procinfo do
    on roles(:all), in: :parallel do |host|
      procinfo = capture('cat /proc/cpuinfo')
      puts "#{host.hostname}:\n#{procinfo}"
    end
  end

  task :meminfo do
    on roles(:all), in: :parallel do |host|
      meminfo = capture('cat /proc/meminfo')
      puts "#{host.hostname}:\n#{meminfo}"
    end
  end
end

namespace :provision do
  task :packages do
    on roles(:all), in: :parallel do
      execute :sudo, 'apt-get -q -y update'
      execute :sudo, 'apt-get -q -y upgrade'
      execute :sudo, 'apt-get install -q -y git nodejs'
    end
  end

  task :rvm do
    on roles(:app), in: :parallel do
      execute '\curl -sSL https://get.rvm.io | bash'
      execute 'source .profile && rvm install ruby 2.2.1'
      execute 'source .profile && gem install bundler'
    end
  end

  task :github_ssh do
    on roles(:app), in: :parallel do
      set :github_ssk_key, ask('Enter path to Github  SSH key:', `echo $HOME/.ssh/github_rsa`.chomp)
      upload! fetch(:github_ssk_key), '/home/vagrant/.ssh/github_rsa'
      execute 'chmod 600 ~/.ssh/github_rsa'
      execute 'printf "Host github.com\n  User git\n  IdentityFile ~/.ssh/github_rsa" > ~/.ssh/config'
    end
  end

  task :all do
    on roles(:all), in: :parallel do
      invoke 'provision:packages'
      invoke 'provision:rvm'
      invoke 'provision:github_ssh'
    end
  end
end

namespace :deploy do
  namespace :db do
    task :setup do
      on roles(:db), in: :parallel do
        info '[deploy:db:setup] Run `rake db:setup`'
        within current_path do
          with rails_env: fetch(:rails_env) do
            execute :rake, 'db:setup'
          end
        end
      end
    end
  end
end
