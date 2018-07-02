class Invoice < ActiveRecord::Base
	has_many :line_items, :dependent => :destroy, foreign_key: "order_id"
    has_many :items, through: :line_items, foreign_key: "order_id"
    has_many :sites, through: :line_items, foreign_key: "site_id"
    has_many :comments, :dependent => :destroy, foreign_key: "order_id"
    belongs_to :customer

    default_scope {where(:deleted => nil)}
end
