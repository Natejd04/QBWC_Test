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
                :modified_date_range_filter => {"from_modified_date" => "2016-03-01", "to_modified_date" => "2016-03-04"}                
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
            invoice_data[:edit_sq] = qb_inv['edit_sequence']

            if qb_inv['customer_ref']
                invoice_data[:customer_id] = Customer.find_by(listid: qb_inv['customer_ref']['list_id']).id
                invoice_data[:name] = qb_inv['customer_ref']['full_name']
            end
          
            if qb_inv['bill_address']
                invoice_data[:address] = qb_inv['bill_address']['addr1']
                invoice_data[:address2] = qb_inv['bill_address']['addr2']
                invoice_data[:city] = qb_inv['bill_address']['city']
                invoice_data[:state] = qb_inv['bill_address']['state']
                invoice_data[:zip] = qb_inv['bill_address']['postal_code']
            end
            
            if qb_inv['ship_address']
                invoice_data[:ship_address] = qb_inv['ship_address']['addr1']
                invoice_data[:ship_address2] = qb_inv['ship_address']['addr2']
                invoice_data[:ship_address3] = qb_inv['ship_address']['addr3']
                invoice_data[:ship_address4] = qb_inv['ship_address']['addr4']
                invoice_data[:ship_address5] = qb_inv['ship_address']['addr5']
                invoice_data[:ship_city] = qb_inv['ship_address']['city']
                invoice_data[:ship_state] = qb_inv['ship_address']['state']
                invoice_data[:ship_zip] = qb_inv['ship_address']['postal_code']
            end
            
            if qb_inv['sales_rep_ref']
                invoice_data[:rep] = qb_inv['sales_rep_ref']['full_name']
            end
            
            invoice_ref = Order.find_by list_id: invoice_data[:list_id]
            if invoice_ref.blank?
                Order.create(invoice_data)
            
            elsif invoice_ref.updated_at < qb_inv['time_modified']
                invoice_ref.update(invoice_data)
            else
                Rails.logger.info("Invoice hasn't been changed")
            end
            
            # This will be for the line item section
            if qb_inv['invoice_line_ret']
                
                qb_inv['invoice_line_ret'].each do |li|
                # We need to match the lineitem with order id
                li_data[:order_id] = invoice_ref.id

                if li['item_ref']
                    list_id = qb_inv['item_ref']['list_id']
                    if Item.find_by(list_id: list_id).present?
                        li_data[:item_id] = Item.find_by(list_id: list_id).id
#                    It doesn't match, or isn't an inventory item, add it to other
                    else
    #                   87 represents an other item
                        li_data[:item_id] = 87
                    end    

                    li_data[:product_name] = li['item_ref']['full_name']
                end
                
                li_data[:description] = li['description']
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