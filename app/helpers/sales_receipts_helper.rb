module SalesReceiptsHelper

	def self.consumer_chart(timeish = 4.months.ago)
        receipts = where(txn_date: timeish.beginning_of_month..timeish.end_of_month)
        receipts = receipts.select("txn_date, sum(subtotal) as subtotal")
        orders.map do |li|
            {
               c_date: txn_date,
               total_price: subtotal || 0
            }
        end
    end

end
