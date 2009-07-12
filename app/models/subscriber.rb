require 'rubygems'
require 'logger'
require 'stomp'

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
