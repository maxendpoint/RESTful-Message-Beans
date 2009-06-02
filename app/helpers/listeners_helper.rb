module ListenersHelper
  def button_caption(listener)
    listener.status == 'running' ? 'Stop' : 'Start'
  end
end
