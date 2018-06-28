class DashboardController < ApplicationController
	before_action :authenticate_user!

	def line_items_total
		invoice_line_items.map(&:amount).sum
	end

	def index 
		# @readable_month = Time.now.strftime("%B")
		# Without a way to pull journal entries my monthly totals wont match
		#@invoices = Invoice.where(:c_date => 1.month.ago.beginning_of_month..1.month.ago.end_of_month).where.not("c_name LIKE ?", "%* UPP:%")
		# @test_total = @invoices.map(&:line_items).flatten.map(&:amount).sum
		#@test_total = @invoices.map(&:line_items_total).sum
		@orders = Order.where(c_invoiced: nil).where.not(:c_total => 0).where.not(:c_class => nil).where.not(:c_class => "Consumer Direct").where.not(:c_name => "Nate2 Davis").order(:c_class => "ASC")
		@order_total = @orders.sum(:c_total)
		@invoices = Invoice.where(:c_date => Time.now.beginning_of_month..Time.now.end_of_month)
		@inv_dist = @invoices.where(:c_class => "Distributor Channel").where.not(:c_subtotal => 0)
		@log_update = Log.where(worker_name: 'QBWC Updated').last

	# Channel calculations
		@orders_cw = Order.where(:c_date => Time.now.beginning_of_week..Time.now.end_of_week).where.not(:c_name => "Nate2 Davis").sum(:c_total)
	# end channel calc		
		
		@invoice_total = Invoice.where(:c_date => Time.now.beginning_of_month..Time.now.end_of_month).sum(:c_subtotal)
		
		
		# Current month top line sales calculations
		#replace with Account Number 4700
		@journal_debit = Journal.joins(:account_line_items).where(:txn_date => Time.now.beginning_of_month..Time.now.end_of_month).where(["account_line_items.account_type = ? and account_line_items.account_id = ?", "debit", "152"]).sum('account_line_items.amount')
		@inv_gross_total = Invoice.joins(:items).where(:c_date => Time.now.beginning_of_month..Time.now.end_of_month).where("items.account_id = 152").sum("line_items.homecurrency_amount")
		@sr_gross_total = SalesReceipt.joins(:items).where(:txn_date => Time.now.beginning_of_month..Time.now.end_of_month).where("items.account_id = 152").sum("line_items.homecurrency_amount")
		@month_sales_receipts = SalesReceipt.where(:txn_date => Time.now.beginning_of_month..Time.now.end_of_month).sum(:subtotal)
		@month_total = ((@inv_gross_total + @sr_gross_total) - @journal_debit)
		
		# Prior Month Top line sales calculations
		@pm_journal_debit = Journal.joins(:account_line_items).where(:txn_date => 1.month.ago.beginning_of_month..1.month.ago.end_of_month).where(["account_line_items.account_type = ? and account_line_items.account_id = ?", "debit", "152"]).sum('account_line_items.amount')
		@pm_inv_gross_total = Invoice.joins(:items).where(:c_date => 1.month.ago.beginning_of_month..1.month.ago.end_of_month).where("items.account_id = 152").sum("line_items.homecurrency_amount")
		@pm_sr_gross_total = SalesReceipt.joins(:items).where(:txn_date => 1.month.ago.beginning_of_month..1.month.ago.end_of_month).where("items.account_id = 152").sum("line_items.homecurrency_amount")
		@prior_m_total = ((@pm_inv_gross_total + @pm_sr_gross_total) - @pm_journal_debit)
			@vs = ((@month_total - @prior_m_total) / @month_total) * 100
		@open_orders_count = Order.where(c_invoiced: nil).where.not(:c_total => 0).where.not(:c_class => nil).where.not(:c_class => "Consumer Direct").where.not(:c_name => "Nate2 Davis").count

		respond_to do |format|
		    format.html
		    # format.json  {@search = Customer.search(params[:term]) }
		    format.csv { send_data Order.to_csv(@orders), filename: "orders-#{Time.now.strftime("%d-%m-%Y %k%M")}.csv" }
  		end		
	end 

	def search
		render json: @search = Customer.search(params[:term])
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
