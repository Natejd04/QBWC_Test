class ReportsController < ApplicationController
	before_action :authenticate_user!
	def index

	end

	def show
		case params[:id]
		when "customer_sales"
			render_customer_sales
		else
			redirect_to reports_path, alert: "This report doesn't exist."
		end
	end

	def render_customer_sales
		render 'reports/customer_sales'
	end
	
end
