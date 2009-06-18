require 'rubygems'
require 'stomp'

class Subscriber
  attr_accessor :url, :host, :port, :user, :password, :connection
  
  def initialize(params)
    @url = params[:subscriber_url]
    @host = params[:host]
    @port = params[:port]
    @user = params[:user]
    @password = params [:password]
    @connection = nil
  end
  
  def connect
    connection = Stomp::Connection.open(user, password, host, port)
    connection.subscribe url, { :ack => 'auto' } 
  end
  
  def receive
    message = connection.receive
  end
end
