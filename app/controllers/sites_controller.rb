class SitesController < ApplicationController

    def index
        @site = Site.all.order('created_at asc') 
    end
    
  private
    
    def site_params
      params.require(:site).permit(:name, :description, :contact, :phone, :email, :address, :address2, :address3, :address4, :address5, :city, :state, :postal)
    end
    
end
