class LineItem < ActiveRecord::Base
    belongs_to :order
    belongs_to :item
    belongs_to :site
    
    def self.uninvoiced
        where(order_id: Order.uninvoiced.map(&:id) )
    end
end
