class UsersController < ApplicationController
    before_action :authenticate_user!
    # you can use this to make exceptions ", except:[:new, :create, :edit, :update]"
  
  def index
      if current_user.role = "admin"
      @user = User.all.order('created_at asc') 
    else
      redirect_to_user_path(current_user)
    end
  end
  
  def new
      @user = User.new
  end
    
  def create
        @user = User.new(user_params)
        if @user.save
          redirect_to @user, notice: "User was successfully created."
          sign_in @user
        else
          #render :text => "here"
          render action: "new"
        end
  end

  def show
      @user = User.find(params[:id])
      @notify_o = @current_user.recipients.where(:notifiable_type => "Order").limit(10)
      @notify_cm = @current_user.recipients.where(:notifiable_type => "CreditMemo").limit(10)
      @notify_c = @current_user.recipients.where(:notifiable_type => "Customer").limit(10)
  end
      
  def edit
      admin_only
      @user = User.find(params[:id]) 
      end
      
  def update
      @user = User.find(params[:id])
      @user.update(user_params)
      p @user
  end
    
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :role, :avatar)
  end
end
