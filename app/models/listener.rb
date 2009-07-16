
require 'rubygems'
#require 'daemons'
require 'password'
require 'rmb'

class Listener < ActiveRecord::Base
  validates_uniqueness_of :key
  validates_presence_of :key, :subscriber_url, :submitter_delivery_url
  has_many :documents

=begin rdoc
+start_daemon+ is invoked when the daemon associated with this listener is to be started.  
An instance of ListenerClient is created to do the actual work, along with a set of properties needed by the daemon. In this
demo rails app, pressing the *start* button on the Listener index page starts the process.  
The button caption is changed to denote the new state of the daemon.  If the daemon started properly, the value of the pid is shown.
=end  
  def start_daemon
    if !self.running?
      lc = RMB::ListenerClient.new(daemon_properties)
      lc.start
    end
  end
=begin rdoc
+stop_daemon+ is invoked to stop the daemon.  The button caption on the Listener index page is changed to denote the new state of the daemon.
=end
  def stop_daemon
    if self.running?
      lc = RMB::ListenerClient.new(daemon_properties)
      lc.stop
      delete_old_user
    end
  end
=begin rdoc
+pid+ returns the numeric value of the pid associated with this daemon.  If the pid file does not exists, this answers 0.
=end
  def pid
    value = 0
    if running?
      File.open(pid_file, 'r') do |f|
        value = f.gets
      end
    end
    value
  end
=begin rdoc
+pid_file+ returns the full pathname of the file containing the daemon's pid.
=end
  def pid_file
    File.join("#{RAILS_ROOT}", "tmp", "pids", "#{app_name}.pid")
  end
  
=begin rdoc
+running?+ answers true if the daemon's pid_file exists.
=end
  def running?
    File.exists?(pid_file)
  end
=begin rdoc
+app_name+ is the concatenation of "listener_daemon_" and the listener key.
=end
  def app_name
    "listener_daemon_#{key}"
  end
=begin rdoc
+delete_old_user+ looks up the user matching the app_name, and if found, deletes it.
=end  
  def delete_old_user
    old_user = User.find_by_name(app_name)
    User.delete(old_user) if old_user
  end
=begin rdoc
+daemon_properties+ answers a hash of properties.  Starting with an initial copy of the RMB_Properties 
hash, values are set for some keys, and additional key/value pairs are added to support more specialized Subscriber/Submitter behavior.
=end  
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

