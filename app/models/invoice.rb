class Invoice < ActiveRecord::Base
	has_many :line_items, :dependent => :destroy, foreign_key: "invoice_id"
    has_many :items, through: :line_items, foreign_key: "invoice_id"
    has_many :sites, through: :line_items, foreign_key: "site_id"
    has_many :comments, :dependent => :destroy, foreign_key: "invoice_id"
    belongs_to :customer

    default_scope {where(:deleted => nil)}




include ReportsKit::Model
  reports_kit do
    aggregation :sum_of_invoices, [:sum, 'invoices.c_subtotal'] 
    contextual_filter :for_customer, ->(relation, context_params) { relation.where(customer_id: context_params[:customer_id]) }
    dimension :monthly_group, group: "to_char(date_trunc('month', invoices.c_date), 'MM-YY Mon')", order_by: "to_char_date_trunc_month_invoices_c_date_yy_mon DESC"
    # dimension :customer_group, group: '(customers.name)'
    # filter :is_published, :boolean, conditions: ->(relation) { relation.where(status: 'published') }
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
        total_prices = amounts_by_interval(starting.to_date, ending.to_date, interval)
        total_prices_py = amounts_by_interval(starting.to_date.prev_year, ending.to_date.prev_year, interval)
        total_prices = total_prices.merge(total_prices_py)
        total_prices.map do |a, b|
            {
                date: a,
                total: b || 0
            }
        end
    end

    # this interval chart cannot supports multiple customer grouping. 
    def self.amounts_by_interval(starting, ending, interval)
        orders = joins(:items).where(c_date: starting.beginning_of_day..ending.beginning_of_day)
        orders = orders.where("items.account_id = 152")
        orders = orders.group("date_trunc('#{interval}', c_date)")
        orders = orders.select("date_trunc('#{interval}', c_date) as c_date, sum(line_items.homecurrency_amount) as subtotal")
        orders.each_with_object({}) do |order, prices|
            prices[order.c_date.to_date] = order.subtotal.round(2)
        end
    end
end
