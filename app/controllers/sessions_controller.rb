class SessionsController < ApplicationController

    def new
    end
    
    def create
        user = User.authenticate(params[:session][:email], params[:session][:password])
        
        if user.nil?
            flash.now[:error] = "Invalid email/password combination."
            render :new
        else
            sign_in user
            role = user.role
            redirect_to trackings_path
        end
    end
    
    def destroy
        sign_out
        redirect_to signin_path
    end
end