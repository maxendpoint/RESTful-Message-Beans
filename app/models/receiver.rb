require 'rubygems'
require 'logger'
require 'mechanize'
require "app/models/properties.rb"

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
  
  def connect
    #this code requires completion of the User controller in the main app
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
end
