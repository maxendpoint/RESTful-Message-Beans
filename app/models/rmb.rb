#
# RESTful-Message-Beans module
#
# Abstraction which wraps the daemon scripts and
# handles the setup.
#
require 'stomp'
require 'mechanize'

module RMB

  RMB_Properties = {
                      :key => "",                                  #set this to the name of the listener
                      :subscriber => {
                                       :class_name => 'Subscriber' #set this to selected subclass of Subscriber
                                                                   # <== add more properties for your Subscriber here
                                     },
                      :submitter  => {
                                       :class_name => 'Submitter'  #set this to selected subclass of Submitter
                                                                   # <== add more properties for your Submitter here
                                     },
                      :working_dir => "",                          #set this to the RAILS_ROOT directory
                      
                      :daemon_options => { #these options are passed directly to the class method Daemons.run(target, options)
                                              :app_name       => "",                        #custom name for this daemon
                                              :ARGV           => nil,                       #use the program defaults
                                              :dir_mode       => :normal,                   #requires absolute path
                                              :dir            => "",                        #this is set to "#{RAILS_ROOT}/tmp/pids" by 
                                                                                            #ListenerClient
                                              :multiple       => false,                     #this will allow multiple daemons to run
                                              :ontop          => false,                     #
                                              :mode           => :load,
                                              :backtrace      => false,
                                              :monitor        => false,
                                              :log_output     => true,
                                              :keep_pid_files => true,
                                              :hard_exit      => true
                                            }
                   }
                
  LD = "listener_daemon_"
  
  class Subscriber
    def connect
    end
    
    def receive
    end
    
    def properties=(hash)
      @logger = hash[:logger]
    end
  end
  
  class StompSubscriber < Subscriber
    attr_accessor :url, :host, :port, :user, :password, :connection, :logger
    
    def properties=(hash)
      subscriber = hash[:subscriber]
      @url = subscriber[:url] || "/queue/something"
      @host = subscriber[:host] || ""
      @port = subscriber[:port] || 61613
      @user = subscriber[:user] || ""
      @password = subscriber[:password] || ""
      @connection = nil
      super
    end
    
    def connect
      super
      @connection = Stomp::Connection.open(user, password, host, port)
      @connection.subscribe url, { :ack => 'auto' } 
      @logger.info "Waiting for messages in #{url}."
    end
    
    def receive
      super
      message = @connection.receive
      @logger.info "Received message: #{message.inspect}"
      message
    end
  end

  class Submitter
    def properties=(hash)
      @logger = hash[:logger]
    end
    
    def connect
    end
    
    def send(message)
    end
  end
  
  class MechanizeSubmitter < Submitter
    attr_accessor :user, :password, :login_url, :delivery_url, :agent, :logger, :agent, :daemon_name
    
    def properties=(hash)
      super
      @hash = hash
      @daemon_name = "#{LD}#{hash[:key]}"
      submitter = hash[:submitter]
      @user = submitter[:user] || ""
      @password = submitter[:password] || ""
      @login_url = submitter[:login_url] || ""
      @delivery_url = submitter[:delivery_url] || ""
      @agent = WWW::Mechanize.new 
      @agent.user_agent_alias = 'Linux Mozilla'
    end
    
    def connect
      super
      #this code requires completion of the User controller in the main app
    end
    
    def marshal_message_body(message)
      file = File.join("#{@hash[:working_dir]}", "tmp", "messages", "#{daemon_name}_#{message.headers["timestamp"]}.message")
      File.open(file, "w+") do |f|
        Marshal.dump(message.body, f)
      end
      file
    end
    
    def send(message)
      super
      file = marshal_message_body(message)
      page = agent.get(delivery_url)
      form = page.forms.first
      
      # I can't seem to make the Mechanize code recognize fields as attributes, so
      # I am forced to treat them as an array
      form.fields[1].value = @hash[:key]
      form.fields[2].value = message.headers["destination"]
      form.fields[3].value = message.headers["message-id"]
      form.fields[4].value = message.headers["content-type"]
      form.fields[5].value = message.headers["priority"]
      form.fields[6].value = message.headers["content-length"]
      form.fields[7].value = message.headers["timestamp"]
      form.fields[8].value = message.headers["expires"]
      form.fields[9].value = file
      
      #logger.info "final form: #{form.inspect}"
      
      #submit the form
      page = agent.submit(form)
    end
  end
  
  class ListenerClient
  
    def initialize(hash)
      @hash = hash
      d = @hash[:daemon_options]
      d[:app_name] = "#{LD}#{@hash[:key]}"
      d[:dir] = File.join("#{@hash[:working_dir]}", "tmp", "pids")
      # Ensure the properties folder is present
      properties_dir = File.join("#{@hash[:working_dir]}", "tmp", "properties")
      if !File.directory?(properties_dir)
        Dir.mkdir(properties_dir)
      end
      File.open(File.join("#{properties_dir}", "#{d[:app_name]}.properties"), "w+") do |f|
        YAML.dump(@hash, f)
      end
    end
    
    def start
      control('start')
    end
  
    def stop
      control('stop')
    end
    
    def control(action)
      control_script = "ruby #{File.dirname(__FILE__)}/listener_daemon_control.rb #{action}"
      puts "control_script --> #{control_script}"
      control_params = "#{@hash[:working_dir]} #{@hash[:key]}"
      system("#{control_script} #{control_params} -- #{control_params}")
    end
  end
  
  class ListenerDaemon
    attr_accessor :submitter, :subscriber, :logger, :hash
    
    def initialize(root, key)
      daemon_name = "#{LD}#{key}"
      @logger = Logger.new("#{root}/log/#{daemon_name}.log")
      @logger.info "\nStarting #{File.basename(__FILE__)} --> #{daemon_name}..."
      @hash = nil
      # load the marshalled hash of properties
      f = File.join("#{root}", "tmp", "properties", "#{LD}#{key}.properties")
      File.open(f) do |props|
        @hash = YAML.load(props)
      end
      @hash[:logger] = @logger
      # instantiate the two objects that comprise the front-end and the back-end of 
      # this listener daemon
      front = @hash[:subscriber]
      @subscriber = Kernel.eval "#{front[:class_name]}.new"
      @subscriber.properties=@hash
      back = @hash[:submitter]
      @submitter = Kernel.eval "#{back[:class_name]}.new"
      @submitter.properties=@hash
    end
    
    def run
      subscriber.connect
      logger.info "subscriber connected."
      submitter.connect
      logger.info "submitter logged in."
      logger.info "Waiting for messages in #{subscriber.url}."
      loop do
        message = subscriber.receive
        submitter.send(message)
      end
    end
  end

end

if __FILE__ == $0
  hash = Hash.new
  RMB::RMB_Properties.each do |key,value|
    hash[key] = value
  end
  hash[:key] = 'inventory'
  hash[:working_dir] = '/home/kenb/development/RESTful-Message-Beans'
  hash[:daemon_options][:dir] = File.join("#{hash[:working_dir]}", "tmp", "pids")
  front = hash[:subscriber]
  front[:class_name] = 'StompSubscriber'
  front[:url] = '/topic/inventory'
  front[:host] = 'localhost'
  front[:port] = 61613
  front[:user] = nil
  front[:password] = nil
  back = hash[:submitter]
  back[:class_name] = 'MechanizeSubmitter'
  back[:login_url] = 'http://localhost:3000/login'
  back[:delivery_url] = 'http://localhost:3000/documents/new'
  lc = RMB::ListenerClient.new(hash)
  puts lc.inspect
  lc.start
end
