class AccountsController < ApplicationController

	before_action :admin_only
    
    def create
        @account = Account.new(Accounts_params)
        
        @account.save
        redirect_to @account
    end

    def show
        @account = Account.find(params[:id])
    end
    
    def new
        @account = Account.new
    end
    
    def index
        @account = Account.all
    end
    
    def edit
      @account = Account.find(params[:id])
    end
    
    def update
      @accounts = Account.find(params[:id])
      @accounts.update(Accounts_params)
        redirect_to @accounts
    end
end
