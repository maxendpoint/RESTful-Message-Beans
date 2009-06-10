require 'rubygems'
require 'daemons'
require 'password'

class Listener < ActiveRecord::Base
  validates_uniqueness_of :key
  has_many :documents
  
  def start_daemon
    if self.status != 'running'
      params = Hash.new
      
      subscriber = Hash.new
      subscriber[:url] = self.subscriber_url
      subscriber[:host] = self.subscriber_host
      subscriber[:port] = self.subscriber_port
      subscriber[:user] = self.subscriber_user
      subscriber[:password] = self.subscriber_password
      
      receiver = Hash.new
      receiver[:login_url] = self.receiver_login_url
      receiver[:delivery_url] = self.receiver_delivery_url
      # clear out any old instances of user
      delete_old_user
      # create a new user
      receiver[:user] = app_name
      receiver[:password] = self.receiver_password = PasswordGenerator.new.generate_password(12) 
      User.create(:name                  => receiver[:user],
                  :password              => receiver[:password],
                  :password_confirmation => receiver[:password]) 
      #Marshal properties out to file; to be read by daemon           
      properties = "tmp/daemons/#{app_name}.properties"
      params[:subscriber] = subscriber
      params[:receiver] = receiver
      File.open(properties, "w+") do |f|
        Marshal.dump(params, f)
      end
       # update the Listener instance in the db
      self.status = 'running'
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

  def app_name
    "listener_daemon_#{key}"
  end
  
  def control_daemon(action)
    control_script = "ruby #{File.dirname(__FILE__)}/listener_daemon_control.rb #{action}"
    control_params = "#{key}"
    daemon_params = "#{RAILS_ROOT} #{key}"
    # pass same set of params to both the daemon_control and the daemon itself
    system("#{control_script} #{control_params} -- #{daemon_params}")
  end
  
  def delete_old_user
    old_user = User.find_by_name(app_name)
    User.delete(old_user) if old_user
  end
end

