class CustomersController < ApplicationController
  def index
      @customers = Customer.all.order "id ASC"
  end
    
  def show
     @customer = Customer.find(params[:id]) 
      
  end
end
