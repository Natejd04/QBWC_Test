class Customer < ActiveRecord::Base
    has_many :orders
    has_many :invoices

    def self.search(term)
    	if term.match(/[a-zA-Z]/)
  			where('LOWER(name) LIKE :term', term: "%#{term.downcase}%")
  		else
  			# where('LOWER(name) LIKE :term OR LOWER(city) LIKE :term', term: "%#{term.downcase}%")
			# Order.where('invoice_number LIKE :term')
			joins(:orders).where('orders.invoice_number LIKE :term', term: "#{term}")
  		end
	end

end
