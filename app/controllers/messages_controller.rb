
class MessagesController < ApplicationController

  def index
    @messages = Message.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @listeners }
    end
  end
  
  def new
    @message = Message.new
  end

  def save
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
  
  # DELETE /listeners/1
  # DELETE /listeners/1.xml
  def destroy
    @message = Message.find(params[:id])
    @message.destroy

    respond_to do |format|
      format.html { redirect_to(messages_url) }
      format.xml  { head :ok }
    end
  end

end

