class SalesReceipt < ActiveRecord::Base
	has_many :line_items, :dependent => :destroy, foreign_key: "sales_receipt_id"
    has_many :items, through: :line_items
    has_many :sites, through: :line_items, foreign_key: "site_id"
    has_many :comments, :dependent => :destroy, foreign_key: "sales_receipt_id"
    belongs_to :customer
end
