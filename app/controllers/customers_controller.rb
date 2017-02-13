class CustomersController < ApplicationController
  before_action :authenticate_user, except:[:show]
  def index
      @customers = Customer.all.order "id ASC"
  end
    
  def show
     @customer = Customer.find(params[:id]) 
      
  end
    
  def edit
     @customer = Customer.find(params[:id]) 
      
  end
    
  def update
      @customer = Customer.find(params[:id])
      if @customer.update(customer_params)
          Rails.logger.info "Updated"
      else
#          render "customers/"
          Rails.logger.info "Error on Update"
      end
  end
private
  def customer_params
      params.require(:customer).permit(:name, :address, :address2, :city, :state, :zip, :id, :ship_address, :ship_address2, :ship_address3, :ship_address4, :ship_city, :ship_zip)
  end

end
