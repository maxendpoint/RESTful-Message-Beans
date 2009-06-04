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
  
  def load_properties
  #  debugger
    params = Hash.new
    properties = "#{RAILS_ROOT}/config/daemons/#{app_name}.yml"
    File.open(properties, "r") do |f|
      params = YAML.load(f)
    end
    params
  end
  
  def start_daemon
    if self.status != 'running'
      params = load_properties
 #     debugger
      receiver = params[:receiver]
      subscriber = params[:subscriber]
      # clear out any old instances of user
      delete_old_user
      # create a new user
      receiver[:user] = self.user = app_name
      receiver[:password] = self.password = PasswordGenerator.new.generate_password(12) 
      User.create(:name                  => self.user,
                  :password              => self.password,
                  :password_confirmation => self.password) 
      receiver[:url] = self.receiver_url
      subscriber[:url] = self.subscriber_url
      properties = "#{RAILS_ROOT}/config/daemons/#{app_name}.properties"
      File.open(properties, "w+") do |f|
        Marshal.dump(params, f)
      end
       # update the Listener instance in the db
      self.status = 'running'
      #debugger
      save
      # start the control script
      control_daemon('start')
    end
  end
  
  def stop_daemon
    if self.status == 'running'
      control_daemon('stop')
      delete_old_user
      self.status = 'stopped'
      save
    end
  end

private  
  def delete_old_user
    old_user = User.find_by_name(app_name)
    User.delete(old_user) if old_user
  end
end

