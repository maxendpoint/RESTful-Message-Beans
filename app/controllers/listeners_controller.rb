class ListenersController < ApplicationController
  # GET /listeners
  # GET /listeners.xml
=begin rdoc
 +index+ displays a list of all Listeners defined.
=end
  def index
    @listeners = Listener.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @listeners }
    end
  end

  # GET /listeners/1
  # GET /listeners/1.xml
=begin rdoc
 +show+ show a detailed description of a selected Listener
=end
  def show
    @listener = Listener.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @listener }
    end
  end

  # GET /listeners/new
  # GET /listeners/new.xml
=begin rdoc
 +new+ displays an entry form to create a new Listener instance
=end
  def new
    @listener = Listener.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @listener }
    end
  end

  # GET /listeners/1/edit
=begin rdoc
 +edit+ displays a form containing the contents of the selected Listener, and allows editing of same
=end
  def edit
    @listener = Listener.find(params[:id])
  end

  # POST /listeners
  # POST /listeners.xml
=begin rdoc
 +create+ the successor to +new+, this method accepts the new parameters, creates the new Listener, and puts it in the database.
=end
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
=begin rdoc
 +update+ the successor to +edit+, this method accepts the edit parameters, updates the selected Listener, and updates it in the database.
=end
  def update
    @listener = Listener.find(params[:id])

    respond_to do |format|
      if @listener.update_attributes(params[:listener])
        if @listener.running?
          @listener.stop_daemon
          @listener.start_daemon
          flash[:notice] = 'Listener was modified and restarted.'
        else
          flash[:notice] = 'Listener was successfully updated.'
        end
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
=begin rdoc
 +destroy+ removes the selected Listener from the application, erasing it from the database.
=end
  def destroy
    @listener = Listener.find(params[:id])
    @listener.destroy

    respond_to do |format|
      format.html { redirect_to(listeners_url) }
      format.xml  { head :ok }
    end
  end
  
end
