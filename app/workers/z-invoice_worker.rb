require 'qbwc'

class InvoiceWorker < QBWC::Worker

#    This is the secondary worker that will be ran to keep the rails db updated with new records.
#    If this is the first time setting up this server, do not run this worker first.
#    currently only grabbing 100 results at a time (more like batches of 100)
    def requests(job)
        {
            :invoice_query_rq => {
                :xml_attributes => { "requestID" =>"1", 'iterator'  => "Start" },
                :max_returned => 100,
                :modified_date_range_filter => {"from_modified_date" => "2016-03-02", "to_modified_date" => "2016-03-02"},
                :include_line_items => true
            }
        }
    end
    # :from_modified_date => Customer.order("updated_at").last[:updated_at].strftime("%Y-%m-%d"),
    #             :to_modified_date => DateTime.now.strftime("%Y-%m-%d")

    def handle_response(r, session, job, request, data)
        # handle_response will get customers in groups of 100. When this is 0, we're done.
        complete = r['xml_attributes']['iteratorRemainingCount'] == '0'

        # if no customer updates occured we skip this.
        if r['invoice_ret']

#        We will then loop through each customer and create records.
        r['invoice_ret'].each do |qb_inv|
            invoice_data = {}
            invoice_data[:txn_id] = qb_inv['txn_id']
            invoice_data[:invoice_number] = qb_inv['txn_number']
            invoice_data[:c_edit] = qb_inv['edit_sequence']
            invoice_data[:c_date] = qb_inv['txn_date']

            if qb_inv['po_number']
                invoice_data[:c_po] = qb_inv['po_number']
            end

            if qb_inv['customer_ref']
                invoice_data[:customer_id] = Customer.find_by(list_id: qb_inv['customer_ref']['list_id']).id
                invoice_data[:c_name] = qb_inv['customer_ref']['full_name']
            end
          
            if qb_inv['ship_address']
                invoice_data[:c_ship1] = qb_inv['ship_address']['addr1']
                invoice_data[:c_ship2] = qb_inv['ship_address']['addr2']
                invoice_data[:c_ship3] = qb_inv['ship_address']['addr3']
                invoice_data[:c_ship4] = qb_inv['ship_address']['addr4']
                invoice_data[:c_ship5] = qb_inv['ship_address']['addr5']
                invoice_data[:c_shipcity] = qb_inv['ship_address']['city']
                invoice_data[:c_shipstate] = qb_inv['ship_address']['state']
                invoice_data[:c_shippostal] = qb_inv['ship_address']['postal_code']
                invoice_data[:c_shipcountry] = qb_inv['ship_address']['country']
            end
            
            if qb_inv['sales_rep_ref']
                invoice_data[:c_rep] = qb_inv['sales_rep_ref']['full_name']
            end
            
            invoice_ref = Order.find_by txn_id: invoice_data[:txn_id]
            if invoice_ref.blank?
                Order.create(invoice_data)
            
            elsif invoice_ref.updated_at < qb_inv['time_modified']
                invoice_ref.update(invoice_data)
            else
                Rails.logger.info("Invoice hasn't been changed")
            end
            
            # This will be for the line item section
            if qb_inv['invoice_line_ret']
                # binding.pry
                
                qb_inv['invoice_line_ret'].each do |li|
                # We need to match the lineitem with order id
                li_data = {}

                invoice_ref2 = Order.find_by txn_id: invoice_data[:txn_id]
                li_data[:order_id] = invoice_ref2[:id]
                
# It's still breaking in here somehwere. Nil Nilclass,                 

            if li != {"xml_attributes"=>{}}
                if li['item_ref']
                    # binding.pry
                    list_id = li['item_ref']['list_id']
                    if Item.find_by(list_id: list_id).present?
                        li_data[:item_id] = Item.find_by(list_id: list_id).id
#                    It doesn't match, or isn't an inventory item, add it to other
                    else
    #                   87 represents an other item
                        li_data[:item_id] = 87
                    end    

                    li_data[:product_name] = li['item_ref']['full_name']
                end
            end
                
                if li['description']
                    li_data[:description] = li['description']
                end
                    # Does the line item have a quantity
                li_data[:qty] = li['quantity'].nil? ? nil : li['quantity'].to_i
                    # Does this li have an amount?
                li_data[:amount] = li['amount'].nil? ? nil : li['amount'].to_f
                
                if li['inventory_site_ref']
                    site_id = li['inventory_site_ref']['list_id']
                    li_data[:site_id] = Site.find_by(list_id: site_id).id
                    li_data[:site_name] = li['inventory_site_ref']['full_name']
                end

               
                # Now we need to record these line items
                li_ref = LineItem.find_by txn_id: li['txn_line_id']
                if li_ref.blank?
                    LineItem.create(li_data)
                
                elsif li_ref.updated_at < qb_inv['time_modified']
                    li_ref.update(li_data)
                else
                    Rails.logger.info("Invoice hasn't been changed")
                end
             

            end

              
        end
    end
end
end
end