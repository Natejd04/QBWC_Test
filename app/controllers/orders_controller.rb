class OrdersController < ApplicationController
  
    #checks to make sure a user is logged in before allowing access to files
    before_filter :authenticate_user

  def create
     @order = Order.create( order_params )
      redirect_to :action => :index
  end

  def delete_docs
      @order = Order.find_by_id(params[:id])
      @order.docs = nil
      @order.save
      respond to do |format|
          format.html {redirect_to @order, notice: "Document was deleted"}
      end
  end
  
  def index
#      Need to create a better way to redirect users.
#      If you are a WDS user, you only see the WDS page.
#      This is not quite what I am looking for, this means I will need three
#      template pages, one for each location and an admin (all) view. 
      
  end
    
  def update
      if @order.update(order_params)
          if @order.remove_docs == true
              @order.docs = nil
              @order.save
          end
      end
  end

  def show
      @docs = Order.find(params[:id])
      send_file @docs.docs.path, :type => @docs.docs_content_type, :disposition => 'inline'
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
      params.require(:order).permit(:docs)
  end
end
