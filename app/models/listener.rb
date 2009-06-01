require 'rubygems'
require 'daemons'

class Listener < ActiveRecord::Base

  def app_name
    "listener_daemon_#{id}"
  end
  
  def id_from_name(name)
    name.split('_').last
  end
  
  def launch_template(action)
    control_script = "ruby #{File.dirname(__FILE__)}/listener_daemon_control.rb #{action}"
    control_params = "#{app_name} #{RAILS_ROOT}"
    daemon_params = "-- #{RAILS_ROOT} #{app_name} #{broker_url} #{user} #{password} #{action_url}"
    exec("#{control_script} #{control_params} #{daemon_params}")
  end
  
  def start_daemon
    launch_template('start')
  end
  
  def stop_daemon
    launch_template('stop')
  end
end
