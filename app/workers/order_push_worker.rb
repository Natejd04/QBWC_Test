require 'qbwc'

class OrderPushWorker < QBWC::Worker

    multiline_push = {}
    singleline_push = {}       
    QBPush = Order.where(qb_process: true, qb_sent_time: nil)

    def requests(job)    
    
        if !QBPush.blank?
            QBPush.map do |op|
                    { :sales_order_add_rq => {
                        :xml_attributes => { "requestID" =>"1"},
                        :sales_order_add => {
                            :ref_number => op.invoice_number,
                            :customer_ref => {"list_id" => op.customer.list_id},
                            :ship_address => {
                                "addr1" => op.c_ship1,
                                "addr2" => op.c_ship2,
                                "addr3" => op.c_ship3,
                                "city" => op.c_shipcity,
                                "state" => op.c_shipstate,
                                "postal_code" => op.c_shippostal,
                                "country" => op.c_shipcountry 
                            },
                             :sales_order_line_add => op.line_items.map do |li|
                                {
                                    :item_ref => {:list_id => li.item.list_id},
                                    :desc => li.description
                                }
                            end
                        }
                    }
                }
            end      

        elsif QBPush.is_a? Array
            {
                :sales_order_add_rq => {
                    :xml_attributes => { "requestID" =>"1"},
                    :sales_order_add => {
                        :ref_number => op.invoice_number,
                        :customer_ref => {"list_id" => QBPush.customer.list_id},
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

                if Order.exists?(invoice_number: qb_inv[:ref_number])
                    orderupdate = Order.find_by(invoice_number: qb[:ref_number])
                    # before updating, lets find out if it's neccessary by filtering by modified
                    if orderupdate.c_edit != qb_inv['edit_sequence']
                        invoice_data[:qb_sent_time] = Time.now
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

            if Order.exists?(invoice_number: qb_inv[:ref_number])
                orderupdate = Order.find_by(invoice_number: qb[:ref_number])
                # before updating, lets find out if it's neccessary by filtering by modified
                if orderupdate.c_edit != qb_inv['edit_sequence']
                    invoice_data[:qb_sent_time] = Time.now
                    orderupdate.update(invoice_data)
                end
            end
        end

    	Log.create(worker_name: "OrderPushWorker")


    end
end

