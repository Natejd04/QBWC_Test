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
		# @video = Rails.root.join('private/Animations.mp4')
		@image = "Animations.mp4"
		@video = send_file File.join([Rails.root, "private/", @image]), 
      :disposition => :inline, :stream => true
		# @video = File.join([Rails.root, "private/", "Animations.mp4"])
		render 'reports/video_demo'
		# @video = "Animations.mp4"
		# @video = File.join([Rails.root, "private/", "Animations.mp4"])

	end
end
