class Properties
  attr_accessor :rails_root, :key, :daemon_name, :payload, :logger
  LD = "listener_daemon_"
  
  def initialize(root, key)
    @rails_root = root
    @key = key
    @daemon_name = "#{LD}#{@key}"
    @payload = Hash.new
    @logger = nil
  end
  
  def file_name
    File.join("#{rails_root}", "tmp", "properties", "#{LD}#{key}.properties")
  end
  
  def self.load(root, key)
    result = nil
    f = File.join("#{root}", "tmp", "properties", "#{LD}#{key}.properties")
    File.open(f) do |props|
      result = Marshal.load(props)
    end
   # File.delete(f)
    result
  end
  
  def save
    File.open(file_name, "w+") do |f|
      Marshal.dump(self, f)
    end
  end
end
