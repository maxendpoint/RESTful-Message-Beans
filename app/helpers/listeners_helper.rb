module ListenersHelper
=begin rdoc
+button_caption+  Samples whether a daemon is running, and answers a caption that would change the daemon's state.
=end
  def button_caption(listener)
    listener.running? ? 'Stop' : 'Start'
  end
end
