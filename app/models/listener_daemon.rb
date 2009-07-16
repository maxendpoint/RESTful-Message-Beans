#
# Listener Daemon main program
#

# Value of ARGV[0] => RAILS_ROOT
# Value of ARGV[1] => key
#
# Set the working directory to the RAILS_ROOT of the calling app
#
Dir.chdir(ARGV[0])

require 'rubygems'
require 'logger'
require "#{Dir.getwd}/app/models/rmb" #change this when packaged as a gem

#
# start the daemon worker code...
listener = RMB::ListenerDaemon.new(ARGV[0], ARGV[1])
# ...and listen forever
listener.run


