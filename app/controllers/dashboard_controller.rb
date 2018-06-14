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
		@invoices = Invoice.where(:c_date => 4.month.ago.beginning_of_month..4.month.ago.end_of_month)
		@inv_dist = @invoices.where(:c_class => "Distributor Channel").where.not(:c_subtotal => 0)

		# Let subtract anything that has been deducted from gross sales
		@journal_debit = Journal.joins(:account_line_items).select('journals.id, journals.txn_date, account_line_items.amount, account_line_items.account_id, account_line_items.account_type').where(:journals => {:txn_date => 4.month.ago.beginning_of_month..4.month.ago.end_of_month}).where(:account_line_items => {:account_type => "debit", :account_id => 143}).sum('account_line_items.amount')
		@journal_debit = Invoice.joins(:line_items, :items).select('journals.id, journals.txn_date, line_items.amount, items.account_id').where(:invoices => {:txn_date => 4.month.ago.beginning_of_month..4.month.ago.end_of_month}).where(:items => {:account_id => 143}).sum('line_items.amount')
		# @inv_dist_total = @inv_dist.sum
		@invoice_total = Invoice.where(:c_date => 4.month.ago..4.month.ago.end_of_month).sum(:c_subtotal)
		#@month_total = Invoice.where(:c_date => Time.now.beginning_of_month..Time.now).sum(:c_subtotal)
		#@prior_m_total = Invoice.where(:c_date => 1.month.ago.beginning_of_month..1.month.ago.end_of_month).sum(:c_subtotal)
			#@vs = ((@month_total - @prior_m_total) / @month_total) * 100
		
		# using these just for development, unhide items above in production
		@month_invoice_total = Invoice.where(:c_date => 4.month.ago.beginning_of_month..4.month.ago.end_of_month).sum(:c_subtotal)
		@month_sales_receipts = SalesReceipt.where(:txn_date => 4.month.ago.beginning_of_month..4.month.ago.end_of_month).sum(:subtotal)
		@month_total = (@month_invoice_total + @month_sales_receipts) - @journal_debit
		@prior_m_total = Invoice.where(:c_date => 5.month.ago.beginning_of_month..5.month.ago.end_of_month).sum(:c_subtotal)
			@vs = ((@month_total - @prior_m_total) / @month_total) * 100
		@open_orders_count = Order.where(c_invoiced: nil).count

		respond_to do |format|
		    format.html
		    format.json { @search = Customer.search(params[:term]) }
		    format.csv { send_data Order.to_csv(@orders), filename: "orders-#{Time.now.strftime("%d-%m-%Y %k%M")}.csv" }
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
