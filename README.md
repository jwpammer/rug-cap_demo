# Ruby User Group (DTC) Capistrano Demo
This is a very basic project demonstrating the use of Capistrano for server provisioning and deployment.

The goal is to provision a bare bones Ubuntu instance and get a Rails application deployed and running on that instance.

## Prerequisites
A remote or virtual Ubuntu 14.04 server. For the purposes of this demonstration, [VirtualBox](https://www.virtualbox.org/) and [Vagrant](https://www.vagrantup.com/) will be used.

## Useful links
* [Capistrano](http://capistranorb.com/)
* [Capistrano Gem](https://github.com/capistrano/capistrano)
* [Capistrano Rails](https://github.com/capistrano/rails/)
* [Capistrano Flow](http://capistranorb.com/documentation/getting-started/flow/)
* [Vagrant SSH Keys](https://github.com/mitchellh/vagrant/tree/master/keys)
* [Vagrant Boxes](https://atlas.hashicorp.com/boxes/search)

## From scratch
To start a project of your own from scratch, follow this part of the guide.

```
## Create new Rails project and add to Git
$ rails new rug-cap_demo
$ cd rug-cap_demo
$ git init
$ git commit -am "Initial commit - new/empty Rails project created."

## Scaffold the Rails project
$ rails g scaffold Widget name:string
$ git commit -am "Scaffolding the project to contain a single 'Widget' model for testing."

## Create a new database and generate the schema
$ rake db:create db:migrate
$ git commit -am "Generated database schema."

## Add Capistrano Gems
# Modify Gemfile to include: capistrano, capistrano-rails, capistrano-rvm
$ bundle install
$ git commit -am "Updated Gemfile to include Capistrano related gems."

## Capify Rails project
$ bundle exec cap install
$ git commit -am "Capify-ing the project with default configuration."

## Setup Vagrant
$ mkdir vagrant
$ cd vagrant
$ mkdir ubuntu-14.04-amd64
$ cd ubuntu-14.04-amd64
$ vagrant init
$ git commit -am "Initialized vagrant support."
```

## Continue with real project
Up to this point, it's all been boiler plate setup. The rest of this tutorial leverages branches with each branch containing the required changes to get to the next step. Just look at the delta between each of the branches to follow along.

So, pull down this project and start off with:

```
## Switch to real project
$ git clone git@github.com:jwpammer/rug-cap_demo.git
$ cd rug-cap_demo
$ git checkout demo-start # pick up where we left off

## Configure Vagrant instance
$ git checkout vagrant-config
#> Walk through vagrant/ubuntu/Vagrantfile
$ vagrant up
$ vagrant ssh
#> Walk through vagrant instance

## Create Vagrant Rails environment and Capistrano stage
$ git checkout vagrant-env

## Create Capistrano stats namespace and tasks
$ git checkout cap-stats
$ cap vagrant stats:uptime
$ cap vagrant stats:procinfo
$ cap vagrant stats:meminfo

## Create Capistrano provision namespace and tasks
$ git checkout cap-provision
$ cap vagrant provision:packages
$ cap vagrant provision:rvm
$ cap vagrant provision:github_ssh

## Capistrano application setup and check
$ cap vagrant deploy:check
$ cap vagrant deploy
vagrant$ RAILS_ENV=vagrant bundle exec rails s -b 0.0.0.0 # FAIL - need to bundle

## Capistrano bundler
$ git checkout cap-rvm-bundler
$ cap vagrant deploy
vagrant$ RAILS_ENV=vagrant bundle exec rails s -b 0.0.0.0 # FAIL - need database setup

## Capistrano database setup
$ git checkout cap-database
$ cap vagrant deploy:db:setup
vagrant$ RAILS_ENV=vagrant bundle exec rails s -b 0.0.0.0 # SUCCESS - but can’t find assets

## Capistrano assets pre-compilation
$ git checkout cap-asset
$ cap vagrant deploy
vagrant$ RAILS_ENV=vagrant bundle exec rails s -b 0.0.0.0 # SUCCESS - assets pre-compiled, but not found
vagrant$ RAILS_ENV=vagrant RAILS_SERVE_STATIC_FILES=TRUE bundle exec rails s -b 0.0.0.0 # SUCCESS
```