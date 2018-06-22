class Journal < ActiveRecord::Base
	has_many :account_line_items, :dependent => :destroy, foreign_key: "journal_id"
	has_many :accounts, through: :account_line_items
	default_scope {where(:deleted => nil)}
end
