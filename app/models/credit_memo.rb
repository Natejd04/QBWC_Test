class CreditMemo < ActiveRecord::Base
	has_many :line_items, :dependent => :destroy, foreign_key: "credit_memo_id"
    has_many :items, through: :line_items
    has_many :sites, through: :line_items, foreign_key: "site_id"
    belongs_to :customer

    default_scope {where(:deleted => nil)}



     def self.chart_data(start = 5.months.ago.beginning_of_month, interval)
        total_prices = prices_by_week(start, interval)
        (start.to_date..4.months.ago.end_of_month).map do |date|
        # (5.months.ago.to_date..Date.today).map do |date|
            if !total_prices[date].nil?
                {
                    cr_date: date,
                    total_tpr: total_prices[date] || 0
                }
            else
                {
                    cr_date: date
                }
            end
        end
    end

    def self.prices_by_week(start, interval)
        attributes = %w{610 611 612 613 614}
        credit_memos = joins(:items).where("items.id in (?)", attributes).where(c_date: start.beginning_of_day..Time.zone.now)
        credit_memos = credit_memos.group("date_trunc('#{interval}', credit_memos.c_date)")
        credit_memos = credit_memos.select("date_trunc('#{interval}', credit_memos.c_date) as c_date, sum(line_items.amount) as c_total")
        credit_memos.each_with_object({}) do |order, prices|
            prices[order.c_date.to_date] = order.c_total.round(2)
        end
    end
end
