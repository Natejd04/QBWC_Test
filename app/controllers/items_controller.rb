class ItemsController < ApplicationController
    before_action :authenticate_user, except:[:show]
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
    
    def edit
      @item = Item.find(params[:id])
    end
    
    def update
      @items = Item.find(params[:id])
      @items.update(items_params)
        redirect_to @items
    end

    
end

    private
        def items_params
            params.require(:item).permit(:name, :description, :code, :packsize, :qty, :unit)
    end