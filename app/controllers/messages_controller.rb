
class MessagesController < ApplicationController

  def index
    redirect_to(:action => 'get')
  end
  
  def get
    @message = Message.new
  end
  # . . .



  def save
#    debugger
    @message = Message.new(params[:message])
    if @message.save
      redirect_to(:action => 'show', :id => @message.id)
    else
      render(:action => :get)
    end
  end



  def show
    @message = Message.find(params[:id])
  end



  def message
    @message = Message.find(params[:id])
    send_data(@message.data,
              :filename => @message.name,
              :type => @message.content_type,
              :disposition => "inline")
  end


end

