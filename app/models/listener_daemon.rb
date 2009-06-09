require 'rubygems'
require 'logger'
require 'stomp'
require 'mechanize'

#
# Listener Daemon
#
# Value of ARGV[0] => RAILS_ROOT
  rails_root = ARGV[0]
  Dir.chdir(rails_root)
# Value of ARGV[1] => key
  key = ARGV[1]
  daemon_name = "listener_daemon_#{key}"

# 
# Start the logger
#
  logger = Logger.new("log/#{daemon_name}.log")
  logger.info "\nStarting #{daemon_name}..."
  
#
# Process parameters
#
  0.upto ARGV.length-1 do |i| 
    logger.info "Value of ARGV[#{i}] => #{ARGV[i]}" 
  end
#
# Load the properties file
#
  properties_file = "tmp/daemons/#{daemon_name}.properties"
  logger.info "Properties file = #{properties_file}"
  properties = Marshal.load(File.open(properties_file))
  logger.info "Properties loaded: #{properties.inspect}"
  
  
#
# Log in to receiving server
#

#
# Connect with broker
#
subscriber = properties[:subscriber]
connection = Stomp::Connection.open(subscriber[:user], subscriber[:password], subscriber[:host], subscriber[:port])
connection.subscribe subscriber[:url], { :ack => 'auto' } 
logger.info "Waiting for messages in #{subscriber[:url]}."
#
# Main process loop
#
loop do

  #
  # Wait for message...
  #
  message = connection.receive
  logger.info "Received message: #{message.inspect}"
  logger.info "Message body: #{message.body.inspect}"
  logger.info "Message headers: #{message.headers.inspect}"
  logger.info "Message command: #{message.command.inspect}"
  #
  # Deliver the message
  #
  file = "tmp/messages/#{daemon_name}_#{message.headers["timestamp"]}.message"
  logger.info "file: #{file}"
  File.open(file, "w+") do |f|
    Marshal.dump(message.body, f)
  end
  logger.info "completed marshaling of message.body"
  #
  # scrape the delivery screen
  #
  receiver = properties[:receiver]
  agent = WWW::Mechanize.new 
  logger.info "agent: #{agent}"
  agent.user_agent_alias = 'Linux Mozilla'
  page = agent.get(receiver[:delivery_url])
  logger.info "page: #{page}"
  form = page.forms.first
  logger.info "form: #{form}"
  
  form.fields[1].value = key
  form.fields[2].value = message.headers["destination"]
  form.fields[3].value = message.headers["message-id"]
  form.fields[4].value = message.headers["content-type"]
  form.fields[5].value = message.headers["priority"]
  form.fields[6].value = message.headers["content-length"]
  form.fields[7].value = message.headers["timestamp"]
  form.fields[8].value = message.headers["expires"]
  
  logger.info form.inspect
  
  #submit the form
  page = agent.submit(form)
  logger.info "form submitted"
#
# ...and again
#
end

