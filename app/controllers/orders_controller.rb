class OrdersController < ApplicationController
  
    #checks to make sure a user is logged in before allowing access to files
    #before_filter :authenticate_user
    

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
      @orders = Order.where('c_via=? OR c_via=?', 'LTL from WDS', 'UPS from WDS').where(c_invoiced: nil)
      @order_zing = Order.where('c_via=? OR c_via=?', 'UPS from Zing', 'USPS from Zing').where(c_invoiced: nil)
      @order_art = Order.where('c_via=? OR c_via=?', 'LTL from ART', 'UPS from ART').where(c_invoiced: nil)
      
#      Now we need to grab the inventory data
#      Thanks to @timhugh for coming up with the map solution to this. 
     @inventory_wds = Hash[SiteInventory.select("item_id, qty").where(site_id: 20).order("item_id").group('item_id').sum("qty").map { |k,v| [Item.find(k), v] }]
    @inventory_art = Hash[SiteInventory.select("item_id, qty").where(site_id: 21).order("item_id").group('item_id').sum("qty").map { |k,v| [Item.find(k), v] }]  
    @inventory_zing = Hash[SiteInventory.select("item_id, qty").where(site_id: 22).order("item_id").group('item_id').sum("qty").map { |k,v| [Item.find(k), v] }]  
     
#      These queries are to be used for sales order uninvoiced items
      @inventory_so_wds = Hash[LineItem.uninvoiced.where(site_id: 20).order("item_id").group("item_id").sum("qty").map { |k,v| [Item.find(k), v] }]
      @inventory_so_art = Hash[LineItem.uninvoiced.where(site_id: 21).order("item_id").group("item_id").sum("qty").map { |k,v| [Item.find(k), v] }]
      @inventory_so_zing = Hash[LineItem.uninvoiced.where(site_id: 22).order("item_id").group("item_id").sum("qty").map { |k,v| [Item.find(k), v] }]
      
      
  end
    
  def edit
      @order = Order.find(params[:id])
      @customers = Customer.all
      @items = Item.where("code IS NOT ?", nil)
      @sites = Site.all
  end
    
  def update
      @docs = Order.find(params[:id])
      if order_params[:remove_docs] == "1"
          @docs.docs = nil
      end
      @docs.update(order_params)
  end

  def show
      @order = Order.find(params[:id])
#      send_file @docs.docs.path, :type => @docs.docs_content_type, :disposition => 'inline'
  end

  def new
      @order = Order.new
      10.times {@order.line_items.build}
      @customers = Customer.all
      @items = Item.where("code IS NOT ?", nil)
      @sites = Site.all
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
      @orders = Order.where(c_class: "Wholesale Direct")
      
  end
    
  def admin
      authenticate_admin
  end
    
  def customer_details
      @cust = Customer.find(params[:id])
      respond_to do |format|
          format.js
      end
  end
    
  private
    
  def order_params
      params.require(:order).permit(:docs, :remove_docs, :customer_id, :id, :c_ship, :c_total, :c_po, :c_date, :c_deliver, :c_via, :c_ship1, :c_ship2, :c_ship3, :c_ship4, :c_ship5, :c_shipcity, :c_shipstate, :c_shippostal, line_items_attributes: [ :item_id, :order_id, :qty, :amount, :site_id ])
  end

end
