class DashboardController < ApplicationController
	before_action :authenticate_user!
	helper_method :sort_column, :sort_direction, :classed_remove


	def index 
		# Reused Variables -> just in this controller
		t_now = Time.now
		beg_month = t_now.beginning_of_month
		end_month = t_now.end_of_month
		gs_account_id = "items.account_id = 152"
		prev_beg_month = 1.month.ago.beginning_of_month
		prev_end_month = 1.month.ago.end_of_month
		prev_td_month = 1.month.ago.to_date
		homecurrency = "line_items.homecurrency_amount"
		account_amount = "account_line_items.amount"
		account_array = ["account_line_items.account_type = ? and account_line_items.account_id = ?", "debit", "152"]		

		@orders = Order.dash_orders.where.not(:c_class => classed_remove).order(sort_column + " " + sort_direction)
		@order_total = @orders.sum(:c_total)
		@invoices = Invoice.where(:c_date => beg_month..end_month)
		@inv_dist = @invoices.where(:c_class => "Distributor Channel").where.not(:c_subtotal => 0)
		@log_update = Log.where(:worker_name => "QBWC Updated").last

	# Channel calculations
		@orders_cw = Order.where(:c_date => t_now.beginning_of_week..t_now.end_of_week).where.not(:c_name => "Nate2 Davis").sum(:c_total)
		@invoice_total = Invoice.where(:c_date => beg_month..end_month).sum(:c_subtotal)
				
	# Current month top line sales calculations 
		@journal_debit = Journal.joins(:account_line_items).where(:txn_date => beg_month..end_month).where(account_array).sum(account_amount)
		@inv_gross_total = Invoice.joins(:items).where(:c_date => beg_month..end_month).where(gs_account_id).sum(homecurrency)
		@sr_gross_total = SalesReceipt.joins(:items).where(:txn_date => beg_month..end_month).where(gs_account_id).sum(homecurrency)
		@cm_gross_total = CreditMemo.joins(:items).where(:c_date => beg_month..end_month).where(gs_account_id).sum(homecurrency)
		@month_sales_receipts = SalesReceipt.where(:txn_date => beg_month..end_month).sum(:subtotal)
		@month_total = ((@inv_gross_total + @sr_gross_total) - (@cm_gross_total + @journal_debit))
		
	# Prior Month Top line sales calculations
		@pm_journal_debit = Journal.joins(:account_line_items).where(:txn_date => prev_beg_month..prev_end_month).where(account_array).sum(account_amount)
		@pm_inv_gross_total = Invoice.joins(:items).where(:c_date => prev_beg_month..prev_end_month).where(gs_account_id).sum(homecurrency)
		@pm_sr_gross_total = SalesReceipt.joins(:items).where(:txn_date => prev_beg_month..prev_end_month).where(gs_account_id).sum(homecurrency)
		@pm_cm_gross_total = CreditMemo.joins(:items).where(:c_date => prev_beg_month..prev_end_month).where(gs_account_id).sum(homecurrency)

	# Prior Month To DATE
		@journal_td_debit = Journal.joins(:account_line_items).where(:txn_date => beg_month..t_now).where(account_array).sum(account_amount)
		@inv_gross_td_total = Invoice.joins(:items).where(:c_date => beg_month..t_now).where(gs_account_id).sum(homecurrency)
		@sr_gross_td_total = SalesReceipt.joins(:items).where(:txn_date => beg_month..t_now).where(gs_account_id).sum(homecurrency)
		@cm_gross_td_total = CreditMemo.joins(:items).where(:c_date => beg_month..t_now).where(gs_account_id).sum(homecurrency)
		@month_sales_td_receipts = SalesReceipt.where(:txn_date => beg_month..t_now).sum(:subtotal)
		@month_td_total = ((@inv_gross_td_total + @sr_gross_td_total) - (@cm_gross_td_total + @journal_td_debit))

	#totaling subtotals
		@pmtd_journal_debit = Journal.joins(:account_line_items).where(:txn_date => prev_beg_month..prev_td_month).where(account_array).sum(account_amount)
		@pmtd_inv_gross_total = Invoice.joins(:items).where(:c_date => prev_beg_month..prev_td_month).where(gs_account_id).sum(homecurrency)
		@pmtd_sr_gross_total = SalesReceipt.joins(:items).where(:txn_date => prev_beg_month..prev_td_month).where(gs_account_id).sum(homecurrency)
		@pmtd_cm_gross_total = CreditMemo.joins(:items).where(:c_date => prev_beg_month..prev_td_month).where(gs_account_id).sum(homecurrency)
		@prior_mtd_total = ((@pmtd_inv_gross_total + @pmtd_sr_gross_total) - (@pmtd_cm_gross_total + @pmtd_journal_debit))
		@prior_m_total = ((@pm_inv_gross_total + @pm_sr_gross_total) - (@pm_cm_gross_total + @pm_journal_debit))
			@vs = ((@month_td_total - @prior_mtd_total) / @month_td_total) * 100
		@open_orders_count = Order.dash_orders.where.not(:c_class => classed_remove).count
		
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
