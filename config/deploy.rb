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

set(:latest_release)  { fetch(:current_path) }
set(:release_path)    { fetch(:current_path) }
set(:current_release) { fetch(:current_path) }

set(:current_revision)  { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:latest_revision)   { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:previous_revision) { capture("cd #{current_path}; git rev-parse --short HEAD@{1}").strip }



namespace :deploy do
  desc "Deploy your application"
  task :default do
    update
  end

  desc "Setup your git-based deployment app"
  task :setup, :except => { :no_release => true } do
    dirs = [deploy_to, shared_path]
    dirs += shared_children.map { |d| File.join(shared_path, d) }
    run "#{try_sudo} mkdir -p #{dirs.join(' ')} && #{try_sudo} chmod g+w #{dirs.join(' ')}"
    run "git clone #{repository} #{current_path}"
  end


  task :update do
    transaction do
      update_code
    end
  end

  desc "Update the deployed code."
  task :update_code, :except => { :no_release => true } do
    #run "cd #{current_path}; git fetch origin; git reset --hard #{branch}"
    run "cd #{current_path}; git fetch origin #{branch}; git reset --hard FETCH_HEAD"
    finalize_update
  end

  task :finalize_update, :except => { :no_release => true } do
    run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)
    #ln -sf #{shared_path}/database.yml #{latest_release}/config/database.yml
  end

  namespace :rollback do
    desc "Moves the repo back to the previous version of HEAD"
    task :repo, :except => { :no_release => true } do
      set :branch, "HEAD@{1}"
      deploy.default
    end

    desc "Rewrite reflog so HEAD@{1} will continue to point to at the next previous release."
    task :cleanup, :except => { :no_release => true } do
      run "cd #{current_path}; git reflog delete --rewrite HEAD@{1}; git reflog delete --rewrite HEAD@{1}"
    end

    desc "Rolls back to the previously deployed version."
    task :default do
      rollback.repo
      rollback.cleanup
    end
  end

end

