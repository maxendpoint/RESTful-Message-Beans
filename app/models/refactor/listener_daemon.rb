Dir.chdir(ARGV[0])

require 'rubygems'
require 'properties'
require 'receiver'
require 'subscriber'
#
# Listener Daemon
#
class ListenerDaemon
  attr_accessor :subscriber, :receiver, :logger, :properties
  
  def initialize(argv)
    @properties = Properties.load(argv[0], argv[1])
    @properties.logger = Logger.new(File.join("#{@properties.rails_root}", "log", "listener_daemon_#{@properties.key}.log"))
    @properties.logger.info "Starting #{File.basename(__FILE__)}..."
    @logger = @properties.logger
    @subscriber = Subscriber.new(@properties)
    @receiver = Receiver.new(@properties)
  end
  
  def run
    subscriber.connect
    receiver.login
    loop do
      message = subscriber.receive
      receiver.send(message)
    end
  end
end

#
# main program
#
  listener = ListenerDaemon.new(ARGV)
  listener.logger.info "listener --> #{listener.inspect}"
  listener.run
#
#  test code
#
#argv = Array.new
#argv[0] = '/home/kenb/development/RESTful-Message-Beans'
#argv[1] = 'inventory'
#argv[2] = '<opt> </opt>'

#l = ListenerDaemon.new(argv)
