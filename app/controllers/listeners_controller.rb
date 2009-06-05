class ListenersController < ApplicationController
  # GET /listeners
  # GET /listeners.xml
  def index
    @listeners = Listener.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @listeners }
    end
  end

  # GET /listeners/1
  # GET /listeners/1.xml
  def show
    @listener = Listener.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @listener }
    end
  end

  # GET /listeners/new
  # GET /listeners/new.xml
  def new
    @listener = Listener.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @listener }
    end
  end

  # GET /listeners/1/edit
  def edit
    @listener = Listener.find(params[:id])
  end

  # POST /listeners
  # POST /listeners.xml
  def create
    @listener = Listener.new(params[:listener])

    respond_to do |format|
      if @listener.save
        flash[:notice] = 'Listener was successfully created.'
        format.html { redirect_to(@listener) }
        format.xml  { render :xml => @listener, :status => :created, :location => @listener }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @listener.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /listeners/1
  # PUT /listeners/1.xml
  def update
    @listener = Listener.find(params[:id])

    respond_to do |format|
      if @listener.update_attributes(params[:listener])
        flash[:notice] = 'Listener was successfully updated.'
        format.html { redirect_to(@listener) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @listener.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /listeners/1
  # DELETE /listeners/1.xml
  def destroy
    @listener = Listener.find(params[:id])
    @listener.destroy

    respond_to do |format|
      format.html { redirect_to(listeners_url) }
      format.xml  { head :ok }
    end
  end
  
end
