class Document < ActiveRecord::Base
  belongs_to :listener
  
  def marshal_blob
    self.data = Marshal.load(File.open("#{RAILS_ROOT}/tmp/messages/listener_daemon_#{key}_#{time_stamp}.message"))
  end
  
  def self.create_marshal_file
    data = "inventory data"
    file = "#{RAILS_ROOT}/tmp/messages/listener_daemon_inventory_today.message"
    File.open(file, "w+") do |f|
      Marshal.dump(data, f)
    end
  end
end
