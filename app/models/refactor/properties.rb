#
# Daemon properties
#
require 'logger'

class Properties
  attr_accessor :rails_root, :key, :daemon_name, :payload, :logger
  
  def initialize(root, key)
    @rails_root = root
    @key = key
    @daemon_name = "listener_daemon_#{@key}"
    @payload = Hash.new
    @logger = nil
  end
  
  def file_name
    File.join("#{rails_root}", "tmp", "properties", "listener_daemon_#{key}.properties")
  end
  
  def self.load(root, key)
    result = nil
    f = File.join("#{root}", "tmp", "properties", "listener_daemon_#{key}.properties")
    File.open(f) do |props|
      result = Marshal.load(props)
    end
   # File.delete(f)
    result
  end
  
  def save
 #   debugger
    File.open(file_name, "w+") do |f|
      Marshal.dump(self, f)
    end
  end
end

#properties = Properties.new(ARGV[0], ARGV[1])
#puts "properties --> #{properties.inspect}"



