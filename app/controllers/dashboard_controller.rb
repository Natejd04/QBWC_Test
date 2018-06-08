class DashboardController < ApplicationController
	before_action :authenticate_user

	def line_items_total
		invoice_line_items.map(&:amount).sum
	end

	def index 
		# Without a way to pull journal entries my monthly totals wont match
		#@invoices = Invoice.where(:c_date => 1.month.ago.beginning_of_month..1.month.ago.end_of_month).where.not("c_name LIKE ?", "%* UPP:%")
		# @test_total = @invoices.map(&:line_items).flatten.map(&:amount).sum
		#@test_total = @invoices.map(&:line_items_total).sum
		@orders = Order.where(c_invoiced: nil).where.not(c_total: 0)
		@order_total = @orders.sum(:c_total)
		@invoices = Invoice.where(:c_date => 2.month.ago.beginning_of_month..2.month.ago.end_of_month)
		@inv_dist = @invoices.where(:c_class => "Distributor Channel").where.not(:c_subtotal => 0)
		# @inv_dist_total = @inv_dist.sum
		@invoice_total = Invoice.where(:c_date => 2.month.ago..2.month.ago.end_of_month).sum(:c_subtotal)
		#@month_total = Invoice.where(:c_date => Time.now.beginning_of_month..Time.now).sum(:c_subtotal)
		#@prior_m_total = Invoice.where(:c_date => 1.month.ago.beginning_of_month..1.month.ago.end_of_month).sum(:c_subtotal)
			#@vs = ((@month_total - @prior_m_total) / @month_total) * 100
		
		# using these just for development, unhide items above in production
		@month_total = Invoice.where(:c_date => 2.month.ago.beginning_of_month..2.month.ago.end_of_month).sum(:c_subtotal)
		@prior_m_total = Invoice.where(:c_date => 3.month.ago.beginning_of_month..3.month.ago.end_of_month).sum(:c_subtotal)
			@vs = ((@month_total - @prior_m_total) / @month_total) * 100
		@open_orders_count = Order.where(c_invoiced: nil).count

		respond_to do |format|
		    format.html
		    format.json { @search = Customer.search(params[:term]) }
		    format.csv { send_data @orders.to_csv }
  		end		
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
