class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :admin_only, except:[:edit, :update, :show]
    # before_action :configure_sign_up_params, only: [:create]
    # before_action :configure_account_update_params, only: [:update]
    # you can use this to make exceptions ", except:[:new, :create, :edit, :update]"
  
  def index
      if current_user.role = "admin"
      @user = User.all.order('created_at asc') 
    else
      redirect_to_user_path(current_user)
    end
  end
  
  def new
      # super
      @user = User.new
  end
    
  def create
        # super
        @user = User.new(user_params)
        if @user.save
          redirect_to users_path, notice: "User was successfully created."
          # sign_in @user
        else
          #render :text => "here"
          render action: "new"
        end
  end

  def show
      @user = User.find(params[:id])
      @notify_o = current_user.recipients.where(:notifiable_type => "Order").limit(10)
      @notify_cm = current_user.recipients.where(:notifiable_type => "CreditMemo").limit(10)
      @notify_c = current_user.recipients.where(:notifiable_type => "Customer").limit(10)
  end
      
  def edit
      @user = User.find(params[:id]) 
      end
      
  def update
      @user = User.find(params[:id])
      @user.update(user_params)
      p @user
  end

  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:phone, :avatar, :role])
  # end

  # # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:phone, :avatar, :role])
  # end


  # def destroy
  #       # sign_out
  #       # redirect_to signin_path
  #   end
        
  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :role, :phone, :avatar)
  end
end
