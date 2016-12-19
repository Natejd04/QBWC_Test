class LineItem < ActiveRecord::Base
    belongs_to :order
    belongs_to :item
    belongs_to :site
    after_save :delete_orphaned
    
    def self.uninvoiced
        where(order_id: Order.uninvoiced.map(&:id) )
    end
    
    def delete_orphaned
      delete if persisted? && self.item_id.blank?
    end
end
