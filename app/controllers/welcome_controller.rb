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
		if (params.has_key?(:token) && params.has_key?(:auth_key))
			@token = params[:token]
			@auth_key = params[:auth_key]		
			@db = ApiHook.last
			@ip = request.remote_addr
			@user_auth = params[:auth_key].concat(@ip)
			@db_auth = @db.auth_key.concat(@db.url)
			@user_token = Digest::SHA2.hexdigest("#{@db.salt}#{@token}")
			if @user_token == @db.token && @user_auth == @db_auth
				render :json => {:validated => "webhook-true", :requested => @ip} and return
			else
				error_message(1)
			end
		else
				error_message(2)
		end
	end

	def error_message(er)
		render :json => {:error => er} and return
	end
end
