class Item < ActiveRecord::Base
    has_many :site_inventories
    has_many :sites, through: :site_inventories
end
