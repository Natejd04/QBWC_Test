class SitesController < ApplicationController

    def index
        @site = Site.all.order('created_at asc') 
    end
    
end
