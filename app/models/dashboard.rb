class Dashboard < ActiveRecord::Base

    def to_csv
	# attributes = %w{id c_name c_po c_date c_scac c_bol c_ship c_via c_ship1 c_ship2 c_ship3 c_ship4 c_ship 5 c_shipcity c_shipstate invoice_number customer_id}
	attributes = %w{id c_name}
	li_attributes = %w{order_id qty description}
	li_header = %w{order_id qty description name}
	# li_attributes = %w{id item_id name description qty}
    binding.pry
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


end
