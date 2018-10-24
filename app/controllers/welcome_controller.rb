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
		@ip = request.remote_ip
		@log = Log.where("ip = ? and created_at > ?", @ip, 1.minutes.ago)
		if @log.count > 3
			error_message(3, @ip, "Too many attempts too often")
		else
			if (params.has_key?(:token) && params.has_key?(:auth_key))
				@token = params[:token]
				@auth_key = params[:auth_key]		
				@db = ApiHook.last
				@user_auth = @auth_key.concat(@db.url)
				@db_auth = @db.auth_key.concat(@db.url)
				@user_token = Digest::SHA2.hexdigest("#{@db.salt}#{@token}")
				if @user_token == @db.token && @user_auth == @db_auth
					Log.create(:worker_name => "Webhook", :status => "Success", :log_msg => "Sucessful validation of webhook parameters.", :ip => @ip)
					render :json => {:validated => "webhook-true", :requested => @ip} and return
				else
					error_message(1, @ip, "Password was not valid")
				end
			else
					error_message(2, @ip, "Incorrect parameters provided")
			end
		end
	end

	def error_message(er, ip, msg)
		Log.create(:worker_name => "Webhook", :status => "Error", :log_msg => msg, :ip => ip)
		render :json => {:error => er, :uri => ip} and return
	end
end