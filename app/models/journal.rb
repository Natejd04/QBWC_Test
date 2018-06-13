class Journal < ActiveRecord::Base
	has_many :account_line_items, :dependent => :destroy, foreign_key: "journal_id"
end
