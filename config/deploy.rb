#
# Application-specific settings
#
set :rails_env,           "production"
set :application,         'rmb'
#
#Server specific settings
#
set :domain,              'vscdev.com'
set :user,                "vscdevco"
set :password,            "dr8k3sb8d"
set :use_sudo,            false
set :site5_symlink,	  "/home/#{user}/public_html/#{application}"
#
# SCM and repository settings
#
set :scm,                 'git'
set :repository,          "git@github.com:explainer/rmb.git "
set :branch,              'master'
set :scm_verbose,         true
#
# deployment settings
#
set :deploy_to,           "/home/#{user}/#{rails_env}/#{application}"
set :deploy_via,          :remote_cache
set :keep_releases,       5
#
# roles
#
role :app,                domain
role :db,                 domain, :primary => true
role :web,                domain

namespace :deploy do
  task :symlink, :except => { :no_release => true } do
    #
    # In reality, there are two symlinks needed for a complete deploy.
    # The first one creates a 'current' link in the production/application folder to
    # the latest folder in the releases folder
    run "rm -f #{current_path} && ln -s #{latest_release} #{current_path}"
    #
    # The second symlink creates a link in the public_html folder which points to the public
    # folder in 'current'
    run "rm -f #{site5_symlink} && ln -s #{current_path}/public #{site5_symlink}"
  end

  task :start, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
  #
  # task which causes Passenger to initiate a restart
  #
  task :restart do
    run "touch #{current_path}/tmp/restart.txt" 
  end
end













