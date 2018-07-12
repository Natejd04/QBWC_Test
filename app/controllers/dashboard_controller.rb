class DashboardController < ApplicationController
	before_action :authenticate_user!

	helper_method :sort_column, :sort_direction, :classed_remove

	def line_items_total
		invoice_line_items.map(&:amount).sum
	end

	def index 
		# @readable_month = Time.now.strftime("%B")
		# Without a way to pull journal entries my monthly totals wont match
		#@invoices = Invoice.where(:c_date => 1.month.ago.beginning_of_month..1.month.ago.end_of_month).where.not("c_name LIKE ?", "%* UPP:%")
		# @test_total = @invoices.map(&:line_items).flatten.map(&:amount).sum
		#@test_total = @invoices.map(&:line_items_total).sum


		@orders = Order.where(c_invoiced: nil).where.not(:c_total => 0).where.not(:c_class => nil).where.not(:c_class => "Consumer Direct").where.not(:c_name => "Nate2 Davis").where.not(:c_class => classed_remove).order(sort_column + " " + sort_direction)
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

		# Prior Month To DATE
		@journal_td_debit = Journal.joins(:account_line_items).where(:txn_date => Time.now.beginning_of_month..Time.now).where(["account_line_items.account_type = ? and account_line_items.account_id = ?", "debit", "152"]).sum('account_line_items.amount')
		@inv_gross_td_total = Invoice.joins(:items).where(:c_date => Time.now.beginning_of_month..Time.now).where("items.account_id = 152").sum("line_items.homecurrency_amount")
		@sr_gross_td_total = SalesReceipt.joins(:items).where(:txn_date => Time.now.beginning_of_month..Time.now).where("items.account_id = 152").sum("line_items.homecurrency_amount")
		@month_sales_td_receipts = SalesReceipt.where(:txn_date => Time.now.beginning_of_month..Time.now).sum(:subtotal)
		@month_td_total = ((@inv_gross_td_total + @sr_gross_td_total) - @journal_td_debit)

		@pmtd_journal_debit = Journal.joins(:account_line_items).where(:txn_date => 1.month.ago.beginning_of_month..1.month.ago.to_date).where(["account_line_items.account_type = ? and account_line_items.account_id = ?", "debit", "152"]).sum('account_line_items.amount')
		@pmtd_inv_gross_total = Invoice.joins(:items).where(:c_date => 1.month.ago.beginning_of_month..1.month.ago.to_date).where("items.account_id = 152").sum("line_items.homecurrency_amount")
		@pmtd_sr_gross_total = SalesReceipt.joins(:items).where(:txn_date => 1.month.ago.beginning_of_month..1.month.ago.to_date).where("items.account_id = 152").sum("line_items.homecurrency_amount")
		


		@prior_mtd_total = ((@pmtd_inv_gross_total + @pmtd_sr_gross_total) - @pmtd_journal_debit)
		@prior_m_total = ((@pm_inv_gross_total + @pm_sr_gross_total) - @pm_journal_debit)
			@vs = ((@month_td_total - @prior_mtd_total) / @month_td_total) * 100
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

    private

    def sort_column
    	%w[c_ship c_date c_total c_name].include?(params[:sort]) ? params[:sort] : "c_date"
    end

    def sort_direction
    	%w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

    def classed_remove
    	%w[Wholesale\ Direct nil wholesale].include?(params[:remove]) ? params[:remove] : "Wholesale Direct"
    end

end
