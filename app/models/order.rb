class Order < ActiveRecord::Base
    # has_many :docs, :dependent => :delete_docs
    has_many :line_items, :dependent => :destroy
    has_many :items, through: :line_items
    has_many :comments, :dependent => :destroy
    has_many :notifications
    

#    belongs_to :customer, foreign_key: "list_id"
    belongs_to :customer
    accepts_nested_attributes_for :line_items, allow_destroy: true, :reject_if => proc { |a| a[:item_id].blank? }
    validates :customer_id, presence: true
    
    scope :uninvoiced, -> {Order.where(c_invoiced: nil)}

    default_scope {where(:deleted => nil)}
    
    # Let's put this gem on hold
#    this is used for the paperclip gem, in order to upload pdfs
    # has_attached_file :docs, :url => "/:class/:attachment/:id/:basename.:extension", :path => ":rails_root/public/:class/:attachment/:id/:basename.:extension"
#        :url => "/documents/:id/download"
#    
#    validates_attachment_content_type :file, :content_type => 'text/plain'
    # validates_attachment_content_type :docs, :content_type => "application/pdf"
    # before_post_process :docs
    
    #add more of this crazy model, like validation's and such. You know you want to.
    
    #This is to eliminate extra entries on Orders
    def reject_blank_items(attributes)
      attributes[:product_id].blank? &&
      attributes[:qty].blank?
    end
    
    def reject_no_customer(attributes)
        attributes[:customer_id].blank?
    end

    def single_to_csv
        # attributes = %w{id c_name c_po c_date c_scac c_bol c_ship c_via c_ship1 c_ship2 c_ship3 c_ship4 c_ship 5 c_shipcity c_shipstate invoice_number customer_id}
        attributes = %w{id c_name}
        li_attributes = %w{order_id qty description}
        li_header = %w{order_id qty description name}
        CSV.generate(headers: true) do |csv|
            csv << attributes
            csv << self.attributes.values_at(*attributes)
            csv << li_header
             self.line_items.each do |items|
                row = items.attributes.values_at(*li_attributes)
                item_name = [items.item.name].join(", ")
                row << item_name
                csv << row
            end
        end
    end

    def self.chart_data(start = 1.month.ago.beginning_of_month, interval)
        total_prices = prices_by_week(start, interval)
        (start.to_date..Time.now.end_of_month).map do |date|
        # (5.months.ago.to_date..Date.today).map do |date|
            if !total_prices[date].nil?
                {
                    c_date: date,
                    total_price: total_prices[date] || 0
                }
            else
                {
                    c_date: date
                }
            end
        end
    end

    def self.prices_by_week(start, interval)
        orders = where(c_date: start.beginning_of_day..Time.zone.now)
        orders = where.not("c_name = ?", "Nate2 Davis")
        orders = orders.group("date_trunc('#{interval}', c_date)")
        orders = orders.select("date_trunc('#{interval}', c_date) as c_date, sum(c_total) as c_total").where.not(:customer_id => 1529)
        orders.each_with_object({}) do |order, prices|
            prices[order.c_date.to_date] = order.c_total.round(2)
        end
    end

    def self.donut_chart(timeish = Time.now)
        orders = where(c_date: timeish.beginning_of_month..timeish.end_of_month).where.not("c_class = ? and c_class = ? and c_name = ?", nil, "Consumer Direct", "Nate2 Davis")
        orders = orders.group("c_class")
        orders = orders.select("c_class, sum(c_total) as c_total")
        orders.map do |li|
            {
                label: li.c_class,
                value: li.c_total.round(2)
            }
        end
    end

    def self.bar_chart(timeish = Time.now)
        orders = where(c_date: timeish.beginning_of_month..timeish.end_of_month).where.not("c_class = ? and c_class = ? and c_name = ?", nil, "Consumer Direct", "Nate2 Davis")
        orders = orders.group("c_name")
        orders = orders.select("c_name, sum(c_total) as c_total")
        orders = orders.order("c_total DESC")
        orders = orders.limit(5)
        orders.map do |li|
            {
                name: li.c_name,
                value: li.c_total.round(2)
            }
        end
    end

    
    def self.to_csv(order)
        attributes = %w{id c_name c_po c_date c_scac c_bol c_ship c_via c_ship1 c_ship2 c_ship3 c_ship4 c_ship5 c_shipcity c_shipstate invoice_number customer_id}
        li_attributes = %w{order_id qty description}
        multi_header = %w{order_id qty description name id c_name c_po c_date c_scac c_bol c_ship c_via c_ship1 c_ship2 c_ship3 c_ship4 c_ship5 c_shipcity c_shipstate invoice_number customer_id}
        if order.count < 2
        CSV.generate(headers: true) do |csv|
            csv << attributes
            csv << order[0].attributes.values_at(*attributes)
            csv << li_header
             order[0].line_items.each do |items|
                row = items.attributes.values_at(*li_attributes)
                item_name = [items.item.name].join(", ")
                row << item_name
                csv << row
            end
        end
        else
        CSV.generate(headers: true) do |csv|
        csv << multi_header
            order.each do |orders|
                orders.line_items.each do |items|
                    orderinfo = orders.attributes.values_at(*attributes)
                    # row1 = orderinfo.join(", ")
                    row = items.attributes.values_at(*li_attributes)
                    item_name = [items.item.name].join(", ")
                    row << item_name
                    row += orderinfo
                    csv << row
                end
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
        end
    end
#    This was a test from SO, no succes so far
#    before_save :destroy_doc?
#    
#    def doc_delete
#        @doc_delete ||= "0"
#    end
#    
#    def doc_delete=(value)
#        @doc_delete = value
#    end
#    
#private
#    def destroy_doc?
#        self.doc.clear if @doc_delete == "1"
#    end
#    
end

