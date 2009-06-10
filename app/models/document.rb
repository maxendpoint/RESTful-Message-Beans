class Document < ActiveRecord::Base
  belongs_to :listener
  
  def marshal_blob
    name = "#{RAILS_ROOT}/tmp/messages/listener_daemon_#{key}_#{time_stamp}.message"
    f = File.open(name)
    self.data = Marshal.load(f)
    f.close
    File.delete(name)
  end
  
end
