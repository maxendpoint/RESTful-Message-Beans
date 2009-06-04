require 'rubygems'
require 'daemons'
require 'password'

class Listener < ActiveRecord::Base
  validates_uniqueness_of :key
  
  def app_name
    "listener_daemon_#{key}"
  end
  
  def control_daemon(action)
    control_script = "ruby #{File.dirname(__FILE__)}/listener_daemon_control.rb #{action}"
    control_params = "#{RAILS_ROOT} #{app_name}"
    daemon_params = "-- #{control_params}"
    system("#{control_script} #{control_params} #{daemon_params}")
  end
  
  def start_daemon
    if status != 'running'
      params = Hash.new
      # clear out any old instances of user
      delete_old_user
      # create a new user
      params[:user] = user = app_name
      params[:password] = password = PasswordGenerator.new.generate_password(12) 
      User.create(:name                  => user,
                  :password              => password,
                  :password_confirmation => password) 
      params[:action_url] = action_url
      params[:subscriber_url] = subscriber_url
      marshalling_file = "#{RAILS_ROOT}/tmp/daemons/#{app_name}.yml"
      File.open(marshalling_file, "w+") do |f|
        YAML.dump(params, f)
      end
       # update the Listener instance in the db
      status = 'running'
      debugger
      @status = 'running'
      save!
      # start the control script
      control_daemon('start')
    end
  end
  
  def stop_daemon
    if status == 'running'
      control_daemon('stop')
      delete_old_user
      status = 'stopped'
      save!
    end
  end

private  
  def delete_old_user
    old_user = User.find_by_name(app_name)
    User.delete(old_user) if old_user
  end
end

