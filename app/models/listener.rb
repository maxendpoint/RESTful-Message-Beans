require 'rubygems'
require 'daemons'
require 'ngrams'
require 'yaml'

class Listener < ActiveRecord::Base

  def app_name
    "listener_daemon_#{id}"
  end
  
  def id_from_name(name)
    name.split('_').last
  end
  
  def control_daemon(action)
    control_script = "ruby #{File.dirname(__FILE__)}/listener_daemon_control.rb #{action}"
    control_params = "#{app_name} #{RAILS_ROOT}"
    daemon_params = "-- #{RAILS_ROOT} #{app_name} #{broker_url} #{user} #{password} #{action_url}"
    system("#{control_script} #{control_params} #{daemon_params}")
  end
  
  def start_daemon
 #   debugger
    if self.status != 'running'
   #   debugger
      # clear out any old instances of user
      delete_old_user
      # create a new user
      self.user = app_name
      #generator = PasswordGenerator.new
      self.password = 'big_deal' #generator.generate_password(12)
      User.create(:name                  => self.user,
                  :password              => self.password,
                  :password_confirmation => self.password) 
      # start the control daemon
      control_daemon('start')
      self.status = 'running'
      self.save!
    end
  end
  
  def stop_daemon
#    debugger
    if self.status == 'running'
      control_daemon('stop')
      delete_old_user
      self.status = 'stopped'
      self.save!
    end
  end

private  
  def delete_old_user
    old_user = User.find_by_name(app_name)
    User.delete(old_user) if old_user
  end
end

class PasswordGenerator
  def initialize(file = Ngram::Dictionary::DEFAULT_STORE)
    @dictionary = Ngram:Dictionary.load(file)
  end
  
  def generate_password(length)
    @dictionary.word(length)
  end
end
