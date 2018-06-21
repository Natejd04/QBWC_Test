class SitesController < ApplicationController
before_action :authenticate_user!, except:[:show]

    def index
        @site = Site.all.order('created_at asc') 
    end

    def show
        @site = Site.find(params[:id])
    end

    def edit
        @site = Site.find(params[:id])
    end
    
  private
    
    def site_params
      params.require(:site).permit(:name, :description, :contact, :phone, :email, :address, :address2, :address3, :address4, :address5, :city, :state, :postal)
    end
    
end
