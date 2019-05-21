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
      @notify_o = current_user.recipients.where(:notifiable_type => "Order").order(:created_at => "DESC").limit(10)
      @notify_cm = current_user.recipients.where(:notifiable_type => "CreditMemo").order(:created_at => "DESC").limit(10)
      @notify_c = current_user.recipients.where(:notifiable_type => "Customer").order(:created_at => "DESC").limit(10)
  end
      
  def edit
      @user = User.find(params[:id]) 
      end
      
  def update
      @user = User.find(params[:id])
      @user.update(user_params)
      p @user
  end

  def homepages
     if current_user.homepage == nil
      redirect_to dashboard_path
     elsif current_user.homepage == "fulfillment"
      redirect_to fulfillment_index_path
     else
      redirect_to dashboard_consumer_path
     end
  end

  def qbwc_settings
    if current_user.role = "admin" && current_user.email = "nate@zingbars.com"
      @qbwc = QBWC.jobs
      @initial = QbHelper.first
      @logs = Log.all.order(:created_at => "DESC").limit(5)
    else
      redirect_to users_path, notice: "You do not have access to this page."
    end
  end

  def qbwc_enabled
    worker_name = params[:id]
    enabling = params[:qbwc_enabled]
    QBWC.get_job(worker_name).enabled = enabling
    a = QBWC.get_job(worker_name).enabled?
    respond_to do |format|
      format.js
      format.json {        
        render json: {qbwc_enabled: a, id: worker_name} }
    end
  end

  def qb_helper
    @initial = QbHelper.first
    start_date = params[:start]
    end_date = params[:end]
    initial_tf = params[:initial_load]
    @initial.start = start_date
    @initial.end = end_date
    @initial.initial_load = initial_tf    
    @initial.save
     respond_to do |format|
        format.js
        format.json {
          render json: {initial_load: initial_tf, start: start_date, end: end_date}
        }
      end
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
  
  def qbwc_params
      params.permit(:qbwc_enabled, :id)
  end

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :role, :phone, :avatar)
  end
end
