class Item < ActiveRecord::Base
    # has_many :site_inventories
    has_many :sites
    belongs_to :order
    has_many :invoices
    has_many :sales_receipts
	has_many :credit_memos    
    has_many :line_items
    belongs_to :account, foreign_key: "account_id"

    default_scope {where(:deleted => nil)}


    include ReportsKit::Model
    reports_kit do
        contextual_filter :for_item, ->(relation, context_params) { relation.where(id: context_params[:item_id])}
    end

    def self.inv_chart_data(starting, ending, interval)
        total_prices = amounts_by_interval(starting.to_date, ending.to_date, interval)
        total_prices_py = amounts_by_interval(starting.to_date.prev_year, ending.to_date.prev_year, interval)
        total_prices1 = total_prices.merge(total_prices_py)

        total_prices.map do |c, d|
            ly = 0
            total_prices_py.each do |e, f|
           
                if c.strftime("%m") == e.strftime("%m")
                    ly = f
                end
            end
            {date: c, total: d, total_ly: ly}
        end



        # total_prices.map do |a, b|
        #     {
        #         date: a,
        #         total: b || 0
        #     }
        # end
    end

    # this interval chart cannot supports multiple customer grouping. 
    def self.amounts_by_interval(starting, ending, interval)
        orders = joins(:line_items)
        orders = orders.where("invoices.c_date", starting.beginning_of_day..ending.beginning_of_day)
        orders = orders.where("account_id = 152")
        orders = orders.group("date_trunc('#{interval}', invoices.c_date)")
        orders = orders.order("invoices.c_date asc")
        orders = orders.select("date_trunc('#{interval}', invoices.c_date) as c_date, sum(line_items.homecurrency_amount) as subtotal")
        orders.each_with_object({}) do |order, prices|
            # binding.pry
            prices[order.c_date.to_date] = order.subtotal.round(2)
        end
    end




end
