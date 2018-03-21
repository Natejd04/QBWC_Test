class CustomersController < ApplicationController
  before_action :authenticate_user, except:[:show]
  def index
      @customers = Customer.all.order "id ASC"
      @cust1 = Customer.all.paginate(:page => params[:page], :per_page => 100).order('name ASC')
      # Not using the alphabetical paginate at this time
      # @cust, @alphaParams = Customer.all.alpha_paginate(params[:letter], {:enumerate => true, :class => "pagination pagination"}){|cust| cust.name}
  end
    
  def show
     @customer = Customer.find(params[:id]) 
     @order_total = Order.where(:customer_id => @customer.id).sum(:c_total)
     @order_ytd_total = Order.where(:customer_id => @customer.id, :c_date => Time.now.beginning_of_year..Time.now).sum(:c_total)
     @invoice_total = Invoice.where(:customer_id => @customer.id).sum(:c_subtotal)
     @invoice_ytd_total = Invoice.where(:customer_id => @customer.id, :c_date => Time.now.beginning_of_year..Time.now).sum(:c_subtotal)
      
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
