require 'rubygems'
require 'logger'
require 'stomp'
#
# Listener Daemon
#
# Value of ARGV[0] => RAILS_ROOT
  rails_root = ARGV[0]
# Value of ARGV[1] => listener_daemon_<key>
  daemon_name = ARGV[1]

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
