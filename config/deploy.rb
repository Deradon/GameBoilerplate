set :stages, %w(production)
set :default_stage, "production"
require 'capistrano/ext/multistage'

set :application, "tower_map"

# Use Git source control
set :scm, :git
set :repository,  "https://github.com/Deradon/GameBoilerplate.git"
# Deploy from master branch by default
set :branch,      "master"
set :deploy_via, :remote_cache
set :scm_verbose, true
set :ssh_options, { :forward_agent => true }
set :use_sudo,    false

default_run_options[:pty] = true

