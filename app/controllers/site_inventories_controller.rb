class SiteInventoriesController < ApplicationController
before_action :authenticate_user

    def index
        @siteinv = SiteInventory.all.order('created_at asc')
    end
end
