class DocumentsController < ApplicationController
  # GET /documents
  # GET /documents.xml
  def index
    @page_title = "Documents"
    @documents = Document.all
    session[:doc_count] = 0 if session[:doc_count].nil?
    if request.xhr?
#      debugger
      render(:partial => "documents", :object => @documents) # if session[:doc_count] != @documents.size
      session[:doc_count] = @documents.size
    else
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @documents }
      end
    end
  end

  # GET /documents/1
  # GET /documents/1.xml
  def show
    @document = Document.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @document }
    end
  end

  # GET /documents/new
  # GET /documents/new.xml
  def new
    @document = Document.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @document }
    end
  end

  # POST /documents
  # POST /documents.xml
  def create
    @document = Document.new(params[:document])
    #find the associated listener by key, set its id in the document (belongs_to)
    @document.listener_id = Listener.find_by_key(@document.key).id

    respond_to do |format|
      if @document.save
        flash[:notice] = 'Document was successfully created.'
        format.html { redirect_to(@document) }
        format.xml  { render :xml => @document, :status => :created, :location => @document }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @document.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1
  # DELETE /documents/1.xml
  def destroy
    @document = Document.find(params[:id])
    @document.destroy

    respond_to do |format|
      format.html { redirect_to(documents_url) }
      format.xml  { head :ok }
    end
  end
end
