class Invoice < ActiveRecord::Base
	has_many :line_items, :dependent => :destroy, foreign_key: "invoice_id"
    has_many :items, through: :line_items, foreign_key: "invoice_id"
    has_many :sites, through: :line_items, foreign_key: "site_id"
    belongs_to :customer


scope :fulfill_invoice, -> {Invoice.where(tracking: nil).where(:c_class => "Wholesale Direct").where("c_date > ?", Time.now.beginning_of_year)}

    default_scope {where(:deleted => nil)}




include ReportsKit::Model
  reports_kit do
    aggregation :sum_of_invoices, [:sum, 'line_items.homecurrency_amount']
    contextual_filter :for_customer, ->(relation, context_params) { relation.where(customer_id: context_params[:customer_id])}
    contextual_filter :for_item, ->(relation, context_params) { relation.joins(:line_items).where(item_id: context_params[:item_id])}
    # contextual_filter :for_item, ->(relation, context_params) { relation.where(item_id: context_params[:item_id]) }
    dimension :monthly_group, joins: :items, group: "to_char(date_trunc('month', invoices.c_date), 'MM-YY Mon')", order_by: "to_char_date_trunc_month_invoices_c_date_yy_mon DESC"
    # contextual_filter :for_invoice_items, ->(relation, context_params) {relation.where("items.account_id = 152")}
    # dimension :customer_group, group: '(customers.name)'
    filter :is_accounted, :boolean, conditions: ->(relation) { relation.where("items.account_id = 152") }
    # filter :is_an_item, :boolean, conditions: ->(relation) { relation.where("items.name LIKE ?", "%FG:12/12ct Master%") }
    # filter :for_item, :boolean, conditions: ->(relation) { relation.where("items.account_id = 152") }
    # dimension :date_month, where: "date_trunc(month, invoices.c_date)"
  end

  # STATUSES = %w(draft private published).freeze

  def to_s
     c_name
  end



  def self.inv_csv(order)
        attributes = %w{c_invoicenumber id c_name c_po c_date c_scac c_bol c_ship c_via c_ship1 c_ship2 c_ship3 c_ship4 c_ship5 c_shipcity c_shipstate invoice_number customer_id tracking fob c_subtotal}
        li_attributes = %w{invoice_id qty description homecurrency_amount}
        multi_header = %w{invoice_id qty description homecurrency_amount name code upc account_id c_invoicenumber id c_name c_po c_date c_scac c_bol c_ship c_via c_ship1 c_ship2 c_ship3 c_ship4 c_ship5 c_shipcity c_shipstate customer_id c_subtotal}
        CSV.generate(headers: true) do |csv|
        csv << multi_header
            order.each do |orders|
                orders.line_items.each do |items|
                    orderinfo = orders.attributes.values_at(*attributes)
                    # row1 = orderinfo.join(", ")
                    row = items.attributes.values_at(*li_attributes)
                    row += [items.item.name, items.item.code, items.item.upc, items.item.account_id]
                    row += orderinfo
                    csv << row
                end
            end
        end
    end

    def self.inv_chart_data(starting, ending, interval)
        total_invoices = amounts_by_interval(starting.to_date, ending.to_date, interval)
        total_invoices_py = amounts_by_interval(starting.to_date.prev_year, ending.to_date.prev_year, interval)
        total_srs = SalesReceipt.amounts_by_interval(starting.to_date, ending.to_date, interval)
        total_srs_py = amounts_by_interval(starting.to_date.prev_year, ending.to_date.prev_year, interval)
        total_credits = CreditMemo.amounts_by_interval(starting.to_date, ending.to_date, interval)
        total_credits_py = amounts_by_interval(starting.to_date.prev_year, ending.to_date.prev_year, interval)
        total_journals = Journal.amounts_by_interval(starting.to_date, ending.to_date, interval)
        total_journals_py = amounts_by_interval(starting.to_date.prev_year, ending.to_date.prev_year, interval)
        # total_cy = total_invoices.map do |date, amount|
        #     amount += total_srs.map do |date2, amount2|
        #         if date.between?(date2-1.day, date2+1.day) ? amount2 : 0
        #             amount = amount + amount2
        #         end.sum
        #     end
        #     amount += total_credits.each do |date2, amount2|
        #         if date.between?(date2-1.day, date2+1.day) ? amount2 : 0
        #             amount = amount - amount2
        #         end.sum
        #     end
        #     amount+= total_journals.each do |date2, amount2|
        #         if date.between?(date2-1.day, date2+1.day) ? amount2 : 0
        #             amount = amount + amount2
        #         end.sum
        #     end
        # end    
        # total_py = total_invoices_py.map do |date, amount|
        #     total_srs_py.each do |date2, amount2|
        #         if date.between?(date2-1.day, date2+1.day)
        #             amount = amount + amount2
        #         end
        #     end
        #     total_credits_py.each do |date2, amount2|
        #         if date.between?(date2-1.day, date2+1.day)
        #             amount = amount - amount2
        #         end
        #     end
        #     total_journals_py.each do |date2, amount2|
        #         if date.between?(date2-1.day, date2+1.day)
        #             amount = amount + amount2
        #         end
        #     end
        # end     
        total_invoices.map do |c, d|
            ly = 0
            total_invoices_py.each do |e, f|
           
                if c.strftime("%m") == e.strftime("%m")
                    ly = f
                end
            end
            {date: c+1.day, total: d, total_ly: ly}
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
        orders = joins(:items).where(c_date: starting.beginning_of_day..ending.beginning_of_day)
        orders = orders.where("items.account_id = 152")
        orders = orders.group("date_trunc('#{interval}', c_date)")
        orders = orders.order("c_date asc")
        orders = orders.select("date_trunc('#{interval}', c_date) as c_date, sum(line_items.homecurrency_amount) as subtotal")
        orders.each_with_object({}) do |order, prices|            
            prices[order.c_date.to_date] = order.subtotal.round(2)           
        end
    end
end
