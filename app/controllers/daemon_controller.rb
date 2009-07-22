require 'rmb-rails'
include RMB

class DaemonController < ApplicationController
=begin rdoc
* locates the Listener by its id
* starts the associated daemon with Listener properties
* redirects to Listener#index
=end
  def start
    @listener = Listener.find(params[:id])
    @listener.start_daemon
    redirect_to ({:controller => 'listeners', :action => 'index' })
  end
=begin rdoc
* locates the Listener by its id
* stops the associated daemon 
* redirects to Listener#index
=end
  def stop
    @listener = Listener.find(params[:id])
    @listener.stop_daemon
    redirect_to ({:controller => 'listeners', :action => 'index' })
  end
  
end
