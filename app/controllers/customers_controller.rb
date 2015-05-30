class CustomersController < ApplicationController
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
      params.require(:customer).permit(:name, :address, :address2, :city, :state, :zip)
  end

end
