class ItemsController < ApplicationController
    
    def create
        @item = Item.new(items_params)
        
        @item.save
        redirect_to @item
    end

    def show
        @item = Item.find(params[:id])
    end
    
    def new
        @item = Item.new
    end
    
    def index
        @item = Item.all
    end
end

    private
        def items_params
            params.require(:item).permit(:name, :description, :code, :packsize, :qty, :unit)
    end