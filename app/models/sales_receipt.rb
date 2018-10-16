class SalesReceipt < ActiveRecord::Base
	has_many :line_items, :dependent => :destroy, foreign_key: "sales_receipt_id"
    has_many :items, through: :line_items
    has_many :sites, through: :line_items, foreign_key: "site_id"
    has_many :comments, :dependent => :destroy, foreign_key: "sales_receipt_id"
    belongs_to :customer

    default_scope {where(:deleted => nil)}

    def self.amounts_by_interval(starting, ending, interval)
        orders = joins(:items).where(txn_date: starting.beginning_of_day..ending.beginning_of_day)
        orders = orders.where("items.account_id = 152")
        orders = orders.group("date_trunc('#{interval}', txn_date)")
        orders = orders.order("txn_date asc")
        orders = orders.select("date_trunc('#{interval}', txn_date) as txn_date, sum(line_items.homecurrency_amount) as subtotal")
        orders.each_with_object({}) do |order, prices|
            # binding.pry
            prices[order.txn_date.to_date] = order.subtotal.round(2)
        end
    end

end
