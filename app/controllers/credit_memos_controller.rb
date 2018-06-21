class CreditMemosController < ApplicationController
before_action :authenticate_user!
	def index
		@invoices = CreditMemo.all.order "id ASC"
    	@inv1 = CreditMemo.where("c_date >= ?", 2.months.ago).paginate(:page => params[:page], :per_page => 50).order('c_date ASC')
	end

	def show
      @order = CreditMemo.find(params[:id])
  	end

end
