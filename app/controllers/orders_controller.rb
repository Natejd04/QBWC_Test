class OrdersController < ApplicationController
  
    #checks to make sure a user is logged in before allowing access to files
    before_filter :authenticate_user
    

  def create
#    Use me when testing the multipart upload
#      @order = Order.new(order_params)
#      respond_to do |format|
#        if @order.save
#         
#         if params[:docs]
#             params[:docs].each { |docs|
#                 @order.docs.create(docs: docs)
#                 }
#             end
#        redirect_to :action => :index
#        end
#    end
      
#      I am meant to be used for single upload, working
      @order = Order.create(order_params)
      redirect_to :action => :index
      
  end

  def delete_docs
      @orders = Order.find_by_id(params[:id])
      @orders.docs = nil
      @orders.save
      respond to do |format|
          format.html {redirect_to @orders, notice: "Document was deleted"}
      end
  end
  
  def index
#      Need to create a better way to redirect users.
#      If you are a WDS user, you only see the WDS page.
#      This is not quite what I am looking for, this means I will need three
#      template pages, one for each location and an admin (all) view. 
      @orders = Order.all.order "id ASC"
  end
    
  def edit
      @docs = Order.find(params[:id])
  end
    
  def update
      @docs = Order.find(params[:id])
      if order_params[:remove_docs] == "1"
          @docs.docs = nil
      end
      @docs.update(order_params)
  end

  def show
      @docs = Order.find(params[:id])
#      send_file @docs.docs.path, :type => @docs.docs_content_type, :disposition => 'inline'
  end

  def new
      @order = Order.new
  end
      
  def download
      @docs = Order.find(params[:id])
      send_file @docs.document.path, :type => @docs.document_content_type, :disposition => 'inline'
  end
    
  def art
      authenticate_art
  end

  def wds
      authenticate_wds
  end
    
  def admin
      authenticate_admin
  end
    
  private
    
  def order_params
      params.require(:order).permit(:docs, :remove_docs)
  end
end
