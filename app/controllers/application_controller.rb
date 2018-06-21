class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
#  include SessionsHelper
 
    # #establish the sign in constants
    # def sign_in(user)
    #     session[:user_id] = user.id
    #     self.current_user = user
    # end
    
    # #set the current user
    # def current_user=(user)
    #     @current_user = user
    # end
    
    # #the get method for the user
    # def current_user
    #     @current_user ||= User.find(session[:user_id]) if session[:user_id]
    # end
    # helper_method :current_user
    
    # def signed_in?
    #     !current_user.nil?
    # end
    
    # def sign_out
    #     session[:user_id] = nil
    #     self.current_user = nil 
    # end
    
    # def current_user?(user)
    #     user == current_user
    # end
    
    def deny_access
        redirect_to signin_path, :notice => "Please sign in to access this page."
    end

    def no_access_notify
        redirect_to dashboard_path, :notice => "You do not have appropriate permissions to see this page."
    end
    
    # def authenticate_user
    #     if !signed_in?
    #     deny_access
    #     end
    # end

     def admin_only
        if current_user.role != "admin"
        no_access_notify
        end
    end

    
    
#  Authenticate the wds users definition(model)
    def authenticate_wds
        if current_user.role != "wds" && current_user.role != "admin"
#            flash.now[:error] = "Invalid email/password combination."
        redirect_to signin_path, :notice => "You do not have access to this page."
        end
    end

#    Authenticate the art users, direct them accordingly
    def authenticate_art
        if current_user.role != "art" && current_user.role != "admin"
            redirect_to signin_path, :notice => "You do not have permissions for   this page."
        end
    end
    
#    authenticate the admin users, direct them accordingly
    def authenticate_admin
        if current_user.role != "admin"
            redirect_to signin_path, :notice => "You do not have permissions for   this page."
        end
    end
    
end
