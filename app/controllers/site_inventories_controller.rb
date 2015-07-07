class SiteInventoriesController < ApplicationController

    def index
        @siteinv = SiteInventory.all.order('created_at asc')
    end
end
