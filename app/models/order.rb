class Order < ActiveRecord::Base
    # has_many :docs, :dependent => :delete_docs
    has_many :line_items, :dependent => :destroy
    has_many :items, through: :line_items
    has_many :comments, :dependent => :destroy
    has_many :notifications
    

#    belongs_to :customer, foreign_key: "listid"
    belongs_to :customer
    accepts_nested_attributes_for :line_items, allow_destroy: true, :reject_if => proc { |a| a[:item_id].blank? }
    validates :customer_id, presence: true
    
    scope :uninvoiced, -> {Order.where(c_invoiced: nil)}
    
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

