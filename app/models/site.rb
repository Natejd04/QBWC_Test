class Site < ActiveRecord::Base
    
    has_many :site_inventories
    has_many :items, through: :site_inventories
    
end
