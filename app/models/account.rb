class Account < ActiveRecord::Base
	has_many :journals
	has_many :account_line_items
	has_many :items

end
