class DashboardController < ApplicationController

	def index 
		@orders = Order.where(:c_date => 1.month.ago..Time.now).where.not(c_total: 0)
		@order_total = Order.where(:c_date => 1.month.ago..Time.now).sum(:c_total)
		@invoices = Invoice.where(:c_date => 1.month.ago..Time.now).where.not(c_subtotal: 0)
		@invoice_total = Invoice.where(:c_date => 1.month.ago..Time.now).sum(:c_subtotal)
		@month_total = Invoice.where(:c_date => 1.month.ago..Time.now.end_of_month).sum(:c_subtotal)
		@prior_m_total = Invoice.where(:c_date => Time.now.beginning_of_month - 1.month..Time.now.beginning_of_month - 1.day).sum(:c_subtotal)
			@vs = ((@month_total - @prior_m_total) / @month_total) * 100
		@open_orders_count = Order.where(c_invoiced: nil).count
			
	end

	def customer_details
      @cust = Customer.find(params[:id])
      respond_to do |format|
          format.js
      end

    def _invoices
  		render "_invoices", 
        # locals: { elephant: some_thing },
        layout: false
        
	end
  
  end
end
