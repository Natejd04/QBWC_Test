class Item < ActiveRecord::Base
    # has_many :site_inventories
    has_many :sites
    belongs_to :order
    has_many :invoices
    has_many :sales_receipts
    has_many :line_items
    belongs_to :account, foreign_key: "account_id"
end
