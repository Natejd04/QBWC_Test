class UsersController < ApplicationController
    before_action :authenticate_user, except:[:new, :create]
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
      if current_user.role = "admin"
        else
      redirect_to user_path(current_user)
      end
  end
      
  def edit
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
