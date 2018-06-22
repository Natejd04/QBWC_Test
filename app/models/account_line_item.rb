class AccountLineItem < ActiveRecord::Base
	belongs_to :vendors
	belongs_to :customers
	belongs_to :journals
	belongs_to :account, foreign_key: "account_id"
end
