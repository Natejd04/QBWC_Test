class AccountLineItem < ActiveRecord::Base
	belongs_to :vendors
	belongs_to :customers
	belongs_to :journals
end
