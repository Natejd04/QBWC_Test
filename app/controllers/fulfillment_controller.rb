class FulfillmentController < ApplicationController
  before_action :authenticate_user!
  helper_method :sort_column, :sort_direction, :classed_remove

	def index
		@orders = Order.fulfill_orders
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
