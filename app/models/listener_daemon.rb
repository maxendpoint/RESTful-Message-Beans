RAILS_ROOT = ENV['rails_root']
Dir.chdir(RAILS_ROOT)

require 'rubygems'
require 'logger'
require 'stomp'
require 'mechanize'

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
    File.open(file_name, "w+") do |f|
      Marshal.dump(self, f)
    end
  end
end

class Subscriber
  attr_accessor :url, :host, :port, :user, :password, :connection, :logger
  
  def initialize(prop)
    subscriber = prop.payload[:subscriber]
    @url = subscriber[:url] || "/queue/something"
    @host = subscriber[:host] || ""
    @port = subscriber[:port] || 61613
    @user = subscriber[:user] || ""
    @password = subscriber[:password] || ""
    @connection = nil
    @logger = prop.logger
  end
  
  def connect
    @connection = Stomp::Connection.open(user, password, host, port)
    @connection.subscribe url, { :ack => 'auto' } 
    @logger.info "@connection --> #{@connection.inspect}"
    @logger.info "url, user, password, host, port --> #{url}, #{user}, #{password}, #{host}, #{port}"
    @logger.info "Waiting for messages in #{url}."
  end
  
  def receive
    message = @connection.receive
    @logger.info "Received message: #{message.inspect}"
    message
  end
end

class Receiver
  attr_accessor :user, :password, :login_url, :delivery_url, :agent, :rails_root, :key, :logger, :agent, :daemon_name
  
  def initialize(prop)
    receiver = prop.payload[:receiver]
    @rails_root = prop.rails_root
    @key = prop.key
    @daemon_name = "listener_daemon_#{key}"
    @logger = prop.logger
    @user = receiver[:user] || ""
    @password = receiver[:password] || ""
    @login_url = receiver[:login_url] || ""
    @delivery_url = receiver[:delivery_url] || ""
    @agent = WWW::Mechanize.new 
    @agent.user_agent_alias = 'Linux Mozilla'
    @logger.info "agent: #{agent.inspect}"
  end
  
  def send(message)
    file = File.join("#{@rails_root}", "tmp", "messages", "#{@daemon_name}_#{message.headers["timestamp"]}.message")
    logger.info "message file: #{file}"
    File.open(file, "w+") do |f|
      Marshal.dump(message.body, f)
    end
    logger.info "completed marshalling of message.body"
    page = agent.get(delivery_url)
    form = page.forms.first
    
    # I can't seem to make the Mechanize code recognize fields as attributes, so
    # I am forced to treat them as an array
    form.fields[1].value = key
    form.fields[2].value = message.headers["destination"]
    form.fields[3].value = message.headers["message-id"]
    form.fields[4].value = message.headers["content-type"]
    form.fields[5].value = message.headers["priority"]
    form.fields[6].value = message.headers["content-length"]
    form.fields[7].value = message.headers["timestamp"]
    form.fields[8].value = message.headers["expires"]
    form.fields[9].value = file
    
    logger.info "final form: #{form.inspect}"
    
    #submit the form
    page = agent.submit(form)
  end
  
  def login
    #this code requires completion of the User controller in the main app
  end
end

class ListenerDaemon
  attr_accessor :rails_root, :key, :receiver, :subscriber, :properties, :logger, :daemon_name
  
  def initialize(root, key)
    @rails_root = root
    @key = key
    @daemon_name = "listener_daemon_#{key}"
    @logger = Logger.new("#{@rails_root}/log/#{daemon_name}.log")
    @logger.info "\nStarting #{File.basename(__FILE__)} --> #{daemon_name}..."
    @properties = Properties.load(@rails_root, @key)
    @properties.logger = @logger
    @logger.info "\n@properties --> #{@properties.inspect}"
    @subscriber = Subscriber.new(@properties)
    @receiver = Receiver.new(@properties)
  end
  
  def run
    subscriber.connect
    logger.info "subscriber connected."
    receiver.login
    logger.info "receiver logged in."
    logger.info "Waiting for messages in #{subscriber.url}."
    loop do
      message = subscriber.receive
      receiver.send(message)
    end
  end
end

#
# Listener Daemon main program
#

# Value of ARGV[1] => key
#
# start the daemon worker code...
l = ListenerDaemon.new(RAILS_ROOT, ARGV[0])
#ENV.each do |key,value|
  #l.logger.info "ENV.#{key} => #{value}"
#end
l.logger.info "ENV['rails_root'] => #{ENV['rails_root']}"
# ...and listen forever
l.run


