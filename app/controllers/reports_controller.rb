class ReportsController < ApplicationController
	before_action :authenticate_user!
	def index

	end

	def show
		case params[:id]
		when "customer_sales"
			render_customer_sales
		when "gross_sales"
			render_gross_sales
		when "video_demo"
			render_video_demo
		when "item_sales"
			render_item_sales
		else
			redirect_to reports_path, alert: "This report doesn't exist."
		end
	end

	def render_customer_sales
		render 'reports/customer_sales'
	end

	def render_gross_sales
		if current_user.role == "admin" || current_user.email == "david@zingbars.com"
			render 'reports/gross_sales'
		else
			redirect_to reports_path, alert: "You do not have access to this report."
		end
	end

	def render_video_demo
		render 'reports/video_demo'
	end

	def render_item_sales
		render 'reports/item_sales'
	end
end
