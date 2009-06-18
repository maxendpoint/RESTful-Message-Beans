require 'rubygems'
require 'logger'
require 'stomp'
require 'mechanize'
require 'xmlsimple'

#require 'subscriber'
#require 'receiver'
#
# Listener Daemon
#
# Value of ARGV[0] => RAILS_ROOT
  rails_root = ARGV[0]
  Dir.chdir(rails_root)
# Value of ARGV[1] => key
  key = ARGV[1]
  daemon_name = "listener_daemon_#{key}"
# Value of ARGV[2] => XML representation of properties

# 
# Start the logger
#
  logger = Logger.new("#{rails_root}/log/#{daemon_name}.log")
  logger.info "\nStarting #{File.basename(__FILE__)} --> #{daemon_name}..."
#
# Process parameters
#
  0.upto ARGV.length-1 do |i| 
    logger.info "Value of ARGV[#{i}] => #{ARGV[i]}" 
  end
#
# Load the properties file
#
#  properties_file = "#{rails_root}/tmp/daemons/#{daemon_name}.properties"
  #logger.info "Properties file = #{properties_file}"
  properties = XmlSimple.xml_in(ARGV[2])
  logger.info "Properties loaded: #{properties.inspect}"
  
  
  #xml marshalling creates an extra array around a hash...
  receiver = properties['receiver'][0]
  logger.info "receiver: #{receiver.inspect}"
  subscriber = properties['subscriber'][0]
  logger.info "subscriber: #{subscriber.inspect}"
#
# Log in to receiving server
#

  #not implemented yet

#
# Connect with broker
#
connection = Stomp::Connection.open(subscriber['user'], subscriber['password'], subscriber['host'], subscriber['port'])
connection.subscribe subscriber['url'], { :ack => 'auto' } 
#
# allocate the receiver agent
#
agent = WWW::Mechanize.new 
agent.user_agent_alias = 'Linux Mozilla'
logger.info "agent: #{agent.inspect}"
#
# Main process loop
#
loop do
  logger.info "Waiting for messages in #{subscriber['url']}."
  #
  # Wait for message...
  #
  message = connection.receive
  logger.info "Received message: #{message.inspect}"
  #logger.info "Message body: #{message.body.inspect}"
  #logger.info "Message headers: #{message.headers.inspect}"
  #logger.info "Message command: #{message.command.inspect}"
  #
  # Deliver the message
  #
  file = "#{rails_root}/tmp/messages/#{daemon_name}_#{message.headers["timestamp"]}.message"
  logger.info "file: #{file}"
  File.open(file, "w+") do |f|
    Marshal.dump(message.body, f)
  end
  logger.info "completed marshaling of message.body"
  #
  # scrape the delivery screen
  #
  page = agent.get(receiver['delivery_url'])
  logger.info "page: #{page}"
  form = page.forms.first
  logger.info "form: #{form}"
  
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
  logger.info "form submitted"
#
# ...and again
#
end

