class Journal < ActiveRecord::Base
	has_many :account_line_items, :dependent => :destroy, foreign_key: "journal_id"

	default_scope {where(:deleted => nil)}
end
