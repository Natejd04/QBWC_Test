require 'qbwc'

class OrderPushWorker < QBWC::Worker

QBPush = Order.where(qb_process: true)

    order_push = {}
    s_p = {}
        QBPush.each do |op|
            op.line_items.each do |li|
                # Perform the same layout and do a deep deep_merge
                # Test the each loop hash in the console first

                # example 1
                s_p = {
                    :sales_order_add_rq { 
                        :xml_attributes => {:request_id => "1"},
                        :sales_order_add => {
                            :sales_order_line_add =>
                                :item_ref => {:list_id => li.item.list_id},
                                :desc => li.description
                        }
                    }
                }
                # Now merge them
                s_p = s_p.deep_merge(s_p)
            end

          order_push = {
                :sales_order_add_rq => {
                    :xml_attributes => { "requestID" =>"1"},
                    :sales_order_add => {
                        :customer_ref => {"list_id" => QBPush.customer.listid},
                        :ship_address => {
                            "addr1" => QBPush.c_ship1,
                            "addr2" => QBPush.c_ship2,
                            "addr3" => QBPush.c_ship3,
                            "city" => QBPush.c_shipcity,
                            "state" => QBPush.c_shipstate,
                            "postal_code" => QBPush.c_shippostal,
                            "country" => QBPush.c_shipcountry 
                        },
                            :sales_order_line_add => {
                                :item_ref => {"list_id" => QBPush.line_items[0].item.list_id},
                                "desc" => QBPush.line_items[0].description
                            }
                        
                    }
                }
            }
        end
        # Deep merge the oder_push and s_p
        o_p.each do |p|
            push = {}
            push = s_p.deep_merge(push)
        end

        # Now merget the string of line item adds, and the order request
        hash = {}
        hash = order_push.deep_merge(push)

        #dispaly these results in the Job.




 def requests(job)    

    if QBPush.is_a? Array
            {
                :sales_order_add_rq => {
                	:xml_attributes => { "requestID" =>"1"},
                	:sales_order_add => {
    	                :customer_ref => {"list_id" => QBPush.customer.listid},
                        :ship_address => {
                            "addr1" => QBPush.c_ship1,
                            "addr2" => QBPush.c_ship2,
                            "addr3" => QBPush.c_ship3,
                            "city" => QBPush.c_shipcity,
                            "state" => QBPush.c_shipstate,
                            "postal_code" => QBPush.c_shippostal,
                            "country" => QBPush.c_shipcountry 
                        },
        	                :sales_order_line_add => {
        	                	:item_ref => {"list_id" => QBPush.line_items[0].item.list_id},
                                "desc" => QBPush.line_items[0].description
        	                }
                        
                	}
            	}
            }
        end
    end

    def handle_response(r, session, job, request, data)
        if r['sales_order_ret'].is_a? Array
            r['sales_order_ret'].each do |qb_inv|
                invoice_data = {}
                invoice_data[:txn_id] = qb_inv['txn_id']
                invoice_data[:qb_process] = false
                invoice_data[:c_edit] = qb_inv['edit_sequence']

                if Order.exists?(txn_id: invoice_data[:txn_id])
                    orderupdate = Order.find_by(txn_id: invoice_data[:txn_id])
                    # before updating, lets find out if it's neccessary by filtering by modified
                    if orderupdate.c_edit != qb_inv['edit_sequence']
                        orderupdate.update(invoice_data)
                    end
                end
            end
 
        elsif !r['sales_order_ret'].blank? 
    	    qb_inv = r['sales_order_ret']
            invoice_data = {}
            invoice_data[:txn_id] = qb_inv['txn_id']
            invoice_data[:qb_process] = false
            invoice_data[:c_edit] = qb_inv['edit_sequence']

            if Order.exists?(txn_id: invoice_data[:txn_id])
                orderupdate = Order.find_by(txn_id: invoice_data[:txn_id])
                # before updating, lets find out if it's neccessary by filtering by modified
                if orderupdate.c_edit != qb_inv['edit_sequence']
                    orderupdate.update(invoice_data)
                end
            end
        end

    	Log.create(worker_name: "OrderPushWorker")


    end
end

