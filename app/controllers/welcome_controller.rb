class WelcomeController < ApplicationController
	before_action :authenticate_user!, except: :api
	skip_before_filter :verify_authenticity_token, :only => [:api, :show]
	before_action :validate_webhook

	def show
	end
	
	def api
	end


	private

	def validate_webhook
		if params[:token] == "xyz" && params[:auth_key] == "xyza"
			render :json => {:validated => "webhook-true"}
		else
			render :json => {:validated => "webhook-false"}
		end
	end
end
