require 'rubygems'
require 'logger'
require 'daemons'
require "#{ARGV[1]}/app/models/rmb.rb"
#
# Listener Daemon Control Program
#
#  This ruby script is invoked by the Listener start_daemon and stop_daemon methods
#
    #:app_name:	      The name of the application. This will be used to contruct the name of the pid files and log files. 
    #                 Defaults to the basename of the script.
    #:ARGV:	          An array of strings containing parameters and switches for Daemons. This includes both parameters for Daemons 
    #                 itself and the controlling script. These are assumed to be separated by an array element ’—’, 
    #                 e.g. [‘start’, ‘f’, ’—’, ‘param1_for_script’, ‘param2_for_script’].
    #                 If not given, ARGV (the parameters given to the Ruby process) will be used.
    #:dir_mode:	      Either 
    #    :script      (the directory for writing the pid files to given by :dir is interpreted relative to the script location given by script)  
    #    :normal      (the directory given by :dir is interpreted as a (absolute or relative) path)
    #    :system      (/var/run is used as the pid file directory)
    #:dir:	          Used in combination with :dir_mode (description above)
    #:multiple:	      Specifies whether multiple instances of the same script are allowed to run at the same time
    #:ontop:	        When given (i.e. set to true), stay on top, i.e. do not daemonize the application 
    #                 (but the pid-file and other things are written as usual)
    #:mode:	
    #   :load         Load the script with Kernel.load; 
    #   :exec         Execute the script file with Kernel.exec
    #:backtrace:	    Write a backtrace of the last exceptions to the file ’[app_name].log’ in the pid-file 
    #                 directory if the application exits due to an uncaught exception
    #:monitor:	      Monitor the programs and restart crashed instances
    #:log_output:	    When given (i.e. set to true), redirect both STDOUT and STDERR to a logfile named ’[app_name].output’ in the pid-file directory
    #:keep_pid_files:	When given do not delete lingering pid-files (files for which the process is no longer running).
    #:hard_exit:	    When given use exit! to end a daemons instead of exit (this will for example not call at_exit handlers). 

# Value of ARGV[0] => action (start|stop)
# Value of ARGV[1] => RAILS_ROOT
    Dir.chdir(ARGV[1])
# Value of ARGV[2] => listener key
    key = ARGV[2]
    daemon_name = "listener_daemon_#{key}"
# Value of ARGV[2] => --
# Value of ARGV[3] => listener key

    messages_dir = File.join("#{Dir.getwd}", "tmp", "messages")
    if !File.directory?(messages_dir)
      Dir.mkdir(messages_dir)
    end
    logger = Logger.new("#{Dir.getwd}/log/listener_daemon_control.log")
    logger.info "Starting the #{File.basename(__FILE__)}..."
    0.upto ARGV.length-1 do |i| 
      logger.info "Value of ARGV[#{i}] => #{ARGV[i]}" 
    end

    l = RMB::ListenerDaemon.new(ARGV[1], ARGV[2])
    options = l.hash[:daemon_options]
    options.each do |key, value|
      logger.info "options[#{key}] => #{value}"
    end

    target = File.join("#{Dir.getwd}", "app", "models", "listener_daemon.rb")
    logger.info "Launching #{target}...\n"
    Daemons.run(target, options)
