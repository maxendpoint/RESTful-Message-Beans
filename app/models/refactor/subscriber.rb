require 'rubygems'
require 'stomp'
require 'properties'
require 'logger'

class Subscriber
  attr_accessor :url, :host, :port, :user, :password, :connection, :logger
  
  def initialize(prop)
    subscriber = prop.payload[:subscriber]
    @url = subscriber[:url] || "/queue/something"
    @host = subscriber[:host] || ""
    @port = subscriber[:port] || "61613"
    @user = subscriber[:user] || ""
    @password = subscriber[:password] || ""
    @connection = nil
    @logger = prop.logger
  end
  
  def connect
    @connection = Stomp::Connection.open(user, password, host, port)
    @connection.subscribe url, { :ack => 'auto' } 
    logger.info "Waiting for messages in #{url}."
  end
  
  def receive
    message = @connection.receive
    logger.info "Received message: #{message.inspect}"
  end
end

