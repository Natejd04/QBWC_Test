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
        attributes = %w{id c_name c_po c_date c_scac c_bol c_ship c_via c_ship1 c_ship2 c_ship3 c_ship4 c_ship5 c_shipcity c_shipstate invoice_number customer_id tracking fob}
        #li_attributes = %w{order_id qty description}
        #multi_header = %w{order_id qty description name id c_name c_po c_date c_scac c_bol c_ship c_via c_ship1 c_ship2 c_ship3 c_ship4 c_ship5 c_shipcity c_shipstate invoice_number customer_id}
        #if order.count < 2
        #CSV.generate(headers: true) do |csv|
        #    csv << attributes
        #    csv << order[0].attributes.values_at(*attributes)
        #    csv << li_header
        #     order[0].line_items.each do |items|
        #        row = items.attributes.values_at(*li_attributes)
        #        item_name = [items.item.name].join(", ")
        #        row << item_name
        #        csv << row
        #    end
        #end
        #else
        CSV.generate(headers: true) do |csv|
        csv << attributes
        #csv << multi_header
          order.each do |orders|
            #orders.line_items.each do |items|
                orderinfo = orders.attributes.values_at(*attributes)
                # row1 = orderinfo.join(", ")
                #row = items.attributes.values_at(*li_attributes)
                #item_name = [items.item.name].join(", ")
                #row << item_name
                #row += orderinfo
                csv << orderinfo
            end
          end

            # V1: Older method, probably not as uesful
            #     CSV.generate(headers: true) do |csv|
            # order.each do |orders|
            # csv << attributes
            # csv << orders.attributes.values_at(*attributes)
            # csv << li_header
            #     orders.line_items.each do |items|
            #         row = items.attributes.values_at(*li_attributes)
            #         item_name = [items.item.name].join(", ")
            #         row << item_name
            #         csv << row
            #     end
            #   end
            # end
        #end
    end

end
