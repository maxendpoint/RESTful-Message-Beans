require 'rubygems'
require 'logger'
require 'stomp'
require 'mechanize'

#
# Listener Daemon
#
# Value of ARGV[0] => RAILS_ROOT
  rails_root = ARGV[0]
# Value of ARGV[1] => key
  key = ARGV[1]
  daemon_name = "listener_daemon_#{key}"

# 
# Start the logger
#
  logger = Logger.new("#{rails_root}/log/#{daemon_name}.log")
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
  properties_file = "#{rails_root}/tmp/daemons/#{daemon_name}.properties"
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
user, password = '', ''
host, port = 'localhost', 61613
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
  logger.info "Message body: #{message.body}"
  #
  # Deliver the message
  #
  t = Time.now
  time_stamp = t.strftime("%Y%m%d%H%M%S")
  logger.info "time stamp = #{time_stamp}"
  file = "#{rails_root}/tmp/messages/#{daemon_name}_#{time_stamp}.message"
  File.open(file, "w+") do |f|
    Marshal.dump(message.body, f)
  end
  logger.info "completed marshaling of message.body"
  #
  # scrape the delivery screen
  #
  receiver = properties[:receiver]
  agent = WWW::Mechanize.new # { |a| a.log = Logger.new('scrape.log') }
  agent.user_agent_alias = 'Mac Safari'
  page = agent.get(receiver[:delivery_url])
  delivery_form = page.forms.first
  
  delivery_form.fields[1].value = 'name'
  delivery_form.fields[2].value = key
  delivery_form.fields[3].value = 'comment'
  delivery_form.fields[4].value = 'content-type'
  delivery_form.fields[5].value = time_stamp
  #submit the form
  page = agent.submit(delivery_form)
#
# ...and again
#
end

