require 'qbwc'


class CustomerOrderWorker < QBWC::Worker

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
#            order_data[:c_ack] = qb_cus['edit_sequence']
#            order_data[:c_conf] = qb_cus['edit_sequence']
#            order_data[:c_pro] = qb_cus['edit_sequence']
#            order_data[:c_scac] = qb_cus['edit_sequence']
            order_data[:c_ship] = qb_cus['ship_date']
        order_data[:c_class] = qb_cus['class_ref'].nil? ? nil : qb_cus['class_ref']['full_name']
            order_data[:c_ship1] = qb_cus['ship_address']['addr1']
            order_data[:c_ship2] = qb_cus['ship_address']['addr2']
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
#                li['item_ref']['full_name'] if li['item_ref']
#                Rails.logger.info(qb_cus)
#                Rails.logger.info("------------ NEXT -----------")
#                Rails.logger.info("Item Ref (single), " + li['item_ref'])
                    
                    #####_<<<<<<< Need to fix List_Id ref #######
                    
                
                listid = li['item_ref']['list_id'] if li['item_ref']    
                if Item.find_by(list_id: listid).present?
                    lineitem_data[:product_id] = Item.find_by(list_id:                            listid).id
                else
                    lineitem_data[:product_id] = 79
                end
                    
                lineitem_data[:qty] = li['quantity'].nil? ? nil : li['quantity'].to_i
                lineitem_data[:amount] = li['amount'].nil? ? nil : li['amount'].to_f

                @lineitem = LineItem.create(lineitem_data)
            end
#        qb_cus['sales_order_line_group_ret']['full_name']
#            lineitem_data[:qty] = qb_cus['sales_order_line_group_ret']['quantity']
#            
##            if qb_cus['bill_address']
##                order_data[:address] = qb_cus['bill_address']['addr1']
##                order_data[:address2] = qb_cus['bill_address']['addr2']
##                order_data[:city] = qb_cus['bill_address']['city']
##                order_data[:state] = qb_cus['bill_address']['state']
##                order_data[:zip] = qb_cus['bill_address']['postal_code']
##            end
#            
#           
           
#            order = Order.find_by c_qbid: order_data[:c_qbid]
#            if order.blank?
#                Order.create(order_data)
#            elsif order.updated_at > order.created_at
#                order.update(c_edit: order_data[:c_edit])
#            else order.updated_at = order.created_at
#                order.update(c_edit: order_data[:c_edit])
#                Rails.logger.info("Customer info is the same")
#            end
#            Rails.logger.info(order_data[:c_name] + " @ " + order_data[:c_date])
        end
    
      
 end

    
end