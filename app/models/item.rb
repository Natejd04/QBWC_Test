class Item < ActiveRecord::Base
    # has_many :site_inventories
    has_many :sites
    belongs_to :order
    belongs_to :invoice, foreign_key: "order_id"
    belongs_to :account, foreign_key: "account_id"
end
