require 'rubygems'
require 'logger'
require 'stomp'
#
# Listener Daemon
#
# Value of ARGV[0] => RAILS_ROOT
# Value of ARGV[1] => listener_daemon_<id>, where <id> is the Listener id
# Value of ARGV[2] => subscriber_url
# Value of ARGV[3] => user
# Value of ARGV[4] => password
# Value of ARGV[5] => server_url

# 
# Start the logger
#
  logger = Logger.new("#{ARGV[0]}/log/#{ARGV[1]}.log")
  logger.info "\nStarting #{ARGV[1]}..."

#
# Process parameters
#
  0.upto ARGV.length-1 do |i| 
    logger.info "Value of ARGV[#{i}] => #{ARGV[i]}" 
  end

#
# Log in to server
#

#
# Connect with broker
#

sleepInterval = 20
#
# Main process loop
#
loop do

#
# Wait for message...
#
  logger.info "#{ARGV[1]} is snoozing for #{sleepInterval} seconds..."
  sleep sleepInterval
  logger.info "...Huh? What? Snort!"
#
# Deliver the message
#

#
# ...and again
#
end
