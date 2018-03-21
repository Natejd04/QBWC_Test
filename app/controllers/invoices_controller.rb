class InvoicesController < ApplicationController

	def show
      @order = Invoice.find(params[:id])
  	end

end
