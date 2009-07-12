RAILS_ROOT = ENV['rails_root']
Dir.chdir(RAILS_ROOT)

require 'rubygems'
require 'logger'
require "app/models/properties.rb"
require "app/models/subscriber.rb"
require "app/models/receiver.rb"

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
    #@logger.info "\n@properties --> #{@properties.inspect}"
    @subscriber = Subscriber.new(@properties)
    @receiver = Receiver.new(@properties)
  end
  
  def run
    subscriber.connect
    logger.info "subscriber connected."
    receiver.connect
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

# Value of ARGV[0] => key
#
# start the daemon worker code...
l = ListenerDaemon.new(RAILS_ROOT, ARGV[0])

# ...and listen forever
l.run


