#
# Receiver using WWW:Mechanize implementation
#
require 'rubygems'
require 'stomp'
require 'properties'
require 'mechanize'
require 'logger'

class Receiver
  attr_accessor :user, :password, :login_url, :delivery_url, :agent, :rails_root, :logger
  
  def initialize(prop)
    receiver = prop.payload[:receiver]
    @user = receiver[:user] || ""
    @password = receiver[:password] || ""
    @login_url = receiver[:login_url] || ""
    @delivery_url = receiver[:delivery_url] || ""
    @rails_root = prop.rails_root
    @daemon_name = prop.daemon_name
    @key = prop.key
    @logger = prop.logger
    @agent = WWW::Mechanize.new 
    @agent.user_agent_alias = 'Linux Mozilla'
  end
  
  def send(message)
    logger.info "message --> #{message.inspect}"
    file = File.join("#{rails_root}", "tmp", "messages", "#{daemon_name}_#{message.headers["timestamp"]}.message")
 #   logger.info "file: #{file}"
    File.open(file, "w+") do |f|
      Marshal.dump(message.body, f)
    end
    logger.info "completed marshalling of message.body"
    page = agent.get(delivery_url)
#    logger.info "page: #{page}"
    form = page.forms.first
#    logger.info "form: #{form}"
    
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
    
    logger.info "final form: #{form.inspect}"
    
    #submit the form
    page = agent.submit(form)
  end
  
  def login
  end
end

#
# test code
#
#r = Receiver.new({})
#puts "r --> #{r.inspect}"
