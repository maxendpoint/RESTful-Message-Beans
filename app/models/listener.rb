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
#  submitter_login_url    :string(255)
#  submitter_delivery_url :string(255)
#  submitter_user         :string(255)
#  submitter_password     :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#

require 'rubygems'
#require 'daemons'
require 'password'
require 'rmb'

class Listener < ActiveRecord::Base
  validates_uniqueness_of :key
  validates_presence_of :key, :subscriber_url, :submitter_delivery_url
  has_many :documents
  
  def start_daemon
    if !self.running?
      lc = RMB::ListenerClient.new(daemon_properties)
      lc.start
    end
  end
  
  def stop_daemon
    if self.running?
      lc = RMB::ListenerClient.new(daemon_properties)
      lc.stop
      delete_old_user
    end
  end

  def pid
    value = 0
    if running?
      File.open(pid_file, 'r') do |f|
        value = f.gets
      end
    end
    value
  end
  
  def pid_file
    File.join("#{RAILS_ROOT}", "tmp", "pids", "#{app_name}.pid")
  end
  
  def running?
    File.exists?(pid_file)
  end
  
private  

  def app_name
    "listener_daemon_#{key}"
  end
  
  def delete_old_user
    old_user = User.find_by_name(app_name)
    User.delete(old_user) if old_user
  end
  
  def daemon_properties
    # clear out any old instances of user
    delete_old_user
    
    prop = RMB::RMB_Properties #default set of properties
    
    prop[:working_dir] = RAILS_ROOT
    prop[:key] = self.key
    
    subscriber = prop[:subscriber]
    subscriber[:url] = self.subscriber_url
    subscriber[:host] = self.subscriber_host
    subscriber[:port] = self.subscriber_port
    subscriber[:user] = self.subscriber_user
    subscriber[:password] = self.subscriber_password
    subscriber[:class_name] = 'StompSubscriber'
    
    submitter = prop[:submitter]
    submitter[:login_url] = self.submitter_login_url
    submitter[:delivery_url] = self.submitter_delivery_url
    submitter[:class_name] = 'MechanizeSubmitter'
    # create a new user
    submitter[:user] = self.submitter_user = app_name
    submitter[:password] = self.submitter_password = PasswordGenerator.new.generate_password(12) 
    User.create(:name                  => submitter[:user],
                :password              => submitter[:password],
                :password_confirmation => submitter[:password]) 
    # update the listener instance in the db
    save
    prop
  end

end

