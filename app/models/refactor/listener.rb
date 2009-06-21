# == Schema Information
# Schema version: 20090612010321
#
# Table name: listeners
#
#  id                    :integer(4)      not null, primary key
#  status                :string(255)
#  key                   :string(255)
#  subscriber_url        :string(255)
#  subscriber_host       :string(255)
#  subscriber_port       :integer(4)
#  subscriber_user       :string(255)
#  subscriber_password   :string(255)
#  receiver_login_url    :string(255)
#  receiver_delivery_url :string(255)
#  receiver_user         :string(255)
#  receiver_password     :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#

require 'rubygems'
require 'daemons'
require 'password'

class Listener < ActiveRecord::Base
  validates_uniqueness_of :key
  validates_presence_of :key, :subscriber_url, :receiver_delivery_url
  has_many :documents
  
  def start_daemon
    if self.status != 'running'
 #     debugger
      Listener.create_working_directories
      prop = properties
      receiver = prop.payload[:receiver]
      # clear out any old instances of user
      delete_old_user
      # create a new user
      receiver[:user] = app_name
      receiver[:password] = self.receiver_password = PasswordGenerator.new.generate_password(12) 
      User.create(:name                  => receiver[:user],
                  :password              => receiver[:password],
                  :password_confirmation => receiver[:password]) 
      # commit the daemon properties to a tmp file
      prop.save
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
    control_params = "#{RAILS_ROOT} #{key}"
    # pass the same control params to both the control script and the daemon
    dev_log = " > #{File.join("#{RAILS_ROOT}", "log", "listener_daemon_control_debug.log")} "
    system("#{control_script} #{control_params} -- #{control_params} #{dev_log}")
  end
  
  def delete_old_user
    old_user = User.find_by_name(app_name)
    User.delete(old_user) if old_user
  end
  
  def properties
    prop = Properties.new(RAILS_ROOT, self.key)
    
    subscriber = Hash.new
    subscriber[:url] = self.subscriber_url
    subscriber[:host] = self.subscriber_host
    subscriber[:port] = self.subscriber_port
    subscriber[:user] = self.subscriber_user
    subscriber[:password] = self.subscriber_password
    prop.payload[:subscriber] = subscriber
    
    receiver = Hash.new
    receiver[:login_url] = self.receiver_login_url
    receiver[:delivery_url] = self.receiver_delivery_url
    prop.payload[:receiver] = receiver
    
    prop
  end
  
  #
  # REMOVE THIS CODE AND ADD A CAPISTRANO TASK TO SET UP DIRECTORIES
  #
  def self.create_working_directories
    ['messages', 'properties'].each do |dir|
      f = File.join("#{RAILS_ROOT}", "tmp", "#{dir}")
      if !File.directory?(f)
        Dir.mkdir(f)
      end
    end
  end
end

