class DaemonController < ApplicationController
  
  def start
    @listener = Listener.find(params[:id])
    @listener.start_daemon
    redirect_to ({:controller => 'listeners', :action => 'index' })
  end
  
  def stop
    @listener = Listener.find(params[:id])
    @listener.stop_daemon
    redirect_to ({:controller => 'listeners', :action => 'index' })
  end
  
end
