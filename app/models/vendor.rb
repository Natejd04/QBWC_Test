class Vendor < ActiveRecord::Base
	
	has_many :journals, through: :account_line_items, foreign_key: "vendor_id"

	default_scope {where(:deleted => nil)}

end
