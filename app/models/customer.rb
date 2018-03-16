class Customer < ActiveRecord::Base
    has_many :orders
    has_many :invoices

    def self.search(term)
  		where('LOWER(name) LIKE :term OR LOWER(city) LIKE :term', term: "%#{term.downcase}%")
	end

end
