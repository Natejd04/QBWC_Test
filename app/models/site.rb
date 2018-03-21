class Site < ActiveRecord::Base
    
    # has_many :site_inventories
    has_many :items
    has_many :line_items
    has_many :invoices, through: :line_items
    
end
