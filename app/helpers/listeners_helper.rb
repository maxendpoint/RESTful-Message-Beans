module ListenersHelper
  def button_caption(listener)
    listener.running? ? 'Stop' : 'Start'
  end
end
