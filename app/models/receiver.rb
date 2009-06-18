class Receiver
  attr_accessor :user, :password, :login_url, :delivery_url
  
  def initialize(params)
    @user = params[:user]
    @password = params[:password]
    @login_url = params[:login_url]
    @delivery_url = params[:delivery_url]
  end
  
  def send
  end
end
