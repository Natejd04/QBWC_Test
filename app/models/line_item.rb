class LineItem < ActiveRecord::Base
    belongs_to :order
    belongs_to :item, foreign_key: "item_id"
    belongs_to :site
    belongs_to :invoices, foreign_key: "invoice_id"
    belongs_to :sales_receipts, foreign_key: "sales_receipt_id"
    after_save :delete_orphaned
    belongs_to :credit_memos, foreign_key: "credit_memo_id"
    
    def self.uninvoiced
        where(order_id: Order.uninvoiced.map(&:id) )
    end
    
    def delete_orphaned
      delete if persisted? && self.item_id.blank?
    end
   

end
