require 'qbwc'


class CustomerOrderWorker < QBWC::Worker

#    This is the start of the quickbooks job.
#    The webconnector will ask the QBWC database what worker to run
#    If this is enabled, it will start asking what to do
    def requests(job)
    Rails.logger.info("Starting QBWC Order Worker")
        {
            :sales_order_query_rq => {
                :xml_attributes => { "requestID" =>"1", 'iterator'  => "Start" },
                :max_returned => 50,
                :txn_date_range_filter => { "from_txn_date" => "2015-04-01", "to_txn_date" => "2015-04-02"},
                :include_line_items => true
            }
        }
    end

    def handle_response(r, session, job, request, data)
        # handle_response will get customers in groups of 100. When this is 0, we're done.
        complete = r['xml_attributes']['iteratorRemainingCount'] == '0'
        
#        We will now handle all the responses we received, one at a time
        Rails.logger.info ("---->Attempting Response")
        r['sales_order_ret'].each do |qb_cus|
        order_data = {}
        lineitem_data = {}
            order_data[:c_qbid] = qb_cus['list_id']
            order_data[:c_name] = qb_cus['customer_ref']['full_name']
            order_data[:customer_id] = Customer.find_by(listid: qb_cus['customer_ref']['list_id']).id
#            if customer doesn't exsits there will be a shit storm
            order_data[:c_edit] = qb_cus['edit_sequence']
            order_data[:c_po] = qb_cus['po_number']
            order_data[:c_date] = qb_cus['txn_date']
#           <> order_data[:c_ack] = qb_cus['edit_sequence']
#           <> order_data[:c_conf] = qb_cus['edit_sequence']
#           <> order_data[:c_pro] = qb_cus['edit_sequence']
#           <> order_data[:c_scac] = qb_cus['edit_sequence']
            order_data[:c_ship] = qb_cus['ship_date']
            order_data[:c_class] = qb_cus['class_ref'].nil? ? nil : qb_cus['class_ref']['full_name']
            order_data[:c_ship1] = qb_cus['ship_address']['addr1']
            order_data[:c_ship2] = qb_cus['ship_address']['addr2']
            order_data[:c_ship3] = qb_cus['ship_address']['addr3']
            order_data[:c_ship4] = qb_cus['ship_address']['addr4']
            order_data[:c_ship5] = qb_cus['ship_address']['addr5']
            order_data[:c_shipcity] = qb_cus['ship_address']['city']
            order_data[:c_shipstate] = qb_cus['ship_address']['state']
            order_data[:c_shippostal] = qb_cus['ship_address']['postal_code']
            order_data[:c_shipcountry] = qb_cus['ship_address']['country']
            order_data[:c_invoiced] = qb_cus['is_fully_invoiced']
            order_data[:c_closed] = qb_cus['is_manually_closed']
            order_data[:c_memo] = qb_cus['memo']
            order_data[:c_deliver] = qb_cus['fob']
            order_data[:c_via] = qb_cus['ship_method_ref'].nil? ? nil : qb_cus['ship_method_ref']['full_name']
            order_data[:c_template] = qb_cus['template_ref']['full_name']
            order_data[:c_total] = qb_cus['total_amount']
            
#            submit order create for value
            @order = Order.create(order_data)
            
#            Start lineitem process
            qb_cus['sales_order_line_ret'].each do |li|
                
                lineitem_data[:order_id] = @order.id
    
#                This will weed out wether or not item_ref has a value
                lineitem_data[:description] = li['item_ref']['full_name'] if li['item_ref']
#                lineitem_data[:description] = li['item_ref']['full_name']
                
#                Figure out if item_ref is empty
                listid = li['item_ref']['list_id'] if li['item_ref']    
                
#                does the line_item id match the item field?
                if Item.find_by(list_id: listid).present?
                    lineitem_data[:product_id] = Item.find_by(list_id:                            listid).id
#                It doesn't match, or isn't an inventory item, add it to other
                else
#                    79 represents an other item
                    lineitem_data[:product_id] = 79
                end
                    
#                need to assign all items a site
#                ** site ref doesn't work. eliminate and work of ship location
#                lineitem_data[:site_id] = li['inventory_site_ref']['list_id']
#                lineitem_data[:site_name] = li['inventory_site_location_ref']['full_name'] if li['inventory_site_ref'] 
                
#                make sure that there is a quantity before adding to database
                lineitem_data[:qty] = li['quantity'].nil? ? nil : li['quantity'].to_i
                
#                does this lineitem have an amount?
                lineitem_data[:amount] = li['amount'].nil? ? nil : li['amount'].to_f

#                Create a lineitem entry for the variables above.
#                <>Need to add fields that check to see if this order already exsits
                @lineitem = LineItem.create(lineitem_data)
            
            end
        end
    end
end