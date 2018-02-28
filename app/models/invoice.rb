class Invoice < ActiveRecord::Base
	has_many :line_items
    has_many :items
    belongs_to :customers
end
