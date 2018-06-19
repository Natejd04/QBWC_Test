class Customer < ActiveRecord::Base
    has_many :orders
    has_many :invoices
    has_many :sales_receipts
    has_many :comments
    has_many :journals
    has_many :credit_memos

    default_scope {where(:deleted => nil)}

    def self.search(term)
    	if term.match(/[a-zA-Z]/)
  			where('LOWER(name) LIKE :term', term: "%#{term.downcase}%")
  		elsif term.match(/-{1}\d/)
  			# where('LOWER(name) LIKE :term OR LOWER(city) LIKE :term', term: "%#{term.downcase}%")
			# Order.where('invoice_number LIKE :term')
      includes(:invoices).where('invoices.c_invoicenumber LIKE :term', term: "#{term}").references(:invoices)
    else
			includes(:orders).where('orders.invoice_number LIKE :term', term: "#{term}").references(:orders)
  		end
	end

end
