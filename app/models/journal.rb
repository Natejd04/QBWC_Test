class Journal < ActiveRecord::Base
	has_many :account_line_items, :dependent => :destroy, foreign_key: "journal_id"
	has_many :accounts, through: :account_line_items
	default_scope {where(:deleted => nil)}

	def self.amounts_by_interval(starting, ending, interval)
        orders = joins(:accounts).where(txn_date: starting.beginning_of_day..ending.beginning_of_day)
        orders = orders.where("account_line_items.account_type = ? and account_line_items.account_id = ?", "debit", "152")
        orders = orders.group("date_trunc('#{interval}', txn_date)")
        orders = orders.order("txn_date asc")
        orders = orders.select("date_trunc('#{interval}', txn_date) as txn_date, sum(account_line_items.amount) as subtotal")
        orders.each_with_object({}) do |order, prices|
            # binding.pry
            prices[order.txn_date.to_date] = order.subtotal.round(2)
        end
    end

end
