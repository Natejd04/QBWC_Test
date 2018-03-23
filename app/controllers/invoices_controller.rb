class InvoicesController < ApplicationController

	def index
		@invoices = Invoice.all.order "id ASC"
    	@inv1 = Invoice.where("c_date >= ?", 2.months.ago).paginate(:page => params[:page], :per_page => 50).order('c_date ASC')
	end

	def show
      @order = Invoice.find(params[:id])
  	end

end