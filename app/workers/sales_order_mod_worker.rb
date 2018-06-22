require 'qbwc'

class SalesOrderModWorker < QBWC::Worker

    multiline_push = {}
    singleline_push = {}       
    QBPush = Order.where(send_to_qb: true, qb_sent_time: nil, qb_process: nil)

    def requests(job)    
    
        if !QBPush.blank?
            QBPush.map do |op|
                { 
                    :sales_order_mod_rq => {
                        :xml_attributes => { "requestID" =>"1"},
                        :sales_order_mod => {
                            :txn_id => op.txn_id,
                            :edit_sequence => op.c_edit,
                            :customer_ref => {"list_id" => op.customer.list_id},
                            :f_o_b => op.c_ack,
                            :memo => op.c_memo
                        }
                    }
                }
            end      

        elsif QBPush.is_a? Array
            {
                :sales_order_mod_rq => {
                    :xml_attributes => { "requestID" =>"1"},
                    :sales_order_mod => {
                        :txn_id => op.txn_id,
                        :edit_sequence => op.c_edit,
                        :customer_ref => {"list_id" => op.customer.list_id},
                        :f_o_b => op.c_ack,
                        :memo => op.c_memo
                    }
                }
            }
        end
            
    end

    def handle_response(r, session, job, request, data)
        # binding.pry
        if r['sales_order_ret'].is_a? Array
            r['sales_order_ret'].each do |qb_inv|
                invoice_data = {}
                invoice_data[:c_edit] = qb_inv['edit_sequence']          

                if Order.exists?(txn_id: qb_inv['txn_id'])
                    orderupdate = Order.find_by(txn_id: qb_inv['txn_id'])
                    # before updating, lets find out if it's neccessary by filtering by modified
                    if orderupdate.c_edit != qb_inv['edit_sequence']
                        invoice_data[:qb_sent_time] = Time.now
                        invoice_data[:send_to_qb] = nil
                        orderupdate.update(invoice_data)
                    end
                end
            end
 
        elsif !r['sales_order_ret'].blank? 
    	    qb_inv = r['sales_order_ret']
            invoice_data = {}
            invoice_data[:c_edit] = qb_inv['edit_sequence'] 

            if Order.exists?(txn_id: qb_inv['txn_id'])
                orderupdate = Order.find_by(txn_id: qb_inv['txn_id'])
                # before updating, lets find out if it's neccessary by filtering by modified
                if orderupdate.c_edit != qb_inv['edit_sequence']
                    invoice_data[:qb_sent_time] = Time.now
                    invoice_data[:send_to_qb] = nil
                    orderupdate.update(invoice_data)
                end
            end
        end

    	Log.create(worker_name: "OrderModWorker")


    end
end

