require 'qbwc'
require 'concerns/qbwc_helper'
class OrderPushWorker < QBWC::Worker
    include QbwcHelper

    multiline_push = {}
    singleline_push = {}       
    
    #Was asked to send Amazon DF orders direct to invoice. This naming convention is misleading
    WorkerName = "OrderPushWorker"
    QBPush = Order.where(send_to_qb: true, qb_process: true, qb_sent_time: nil)


    def requests(job)    
    
        if !QBPush.blank?
            QBPush.map do |op|
                    { :sales_order_add_rq => {
                        :xml_attributes => { "requestID" =>"1"},
                        :sales_order_add => {
                            :customer_ref => {"list_id" => op.customer.list_id},
                            :txn_date => op.c_date,
                            :ship_address => {
                                "addr1" => op.c_ship1,
                                "addr2" => op.c_ship2,
                                "addr3" => op.c_ship3,
                                "city" => op.c_shipcity,
                                "state" => op.c_shipstate,
                                "postal_code" => op.c_shippostal,
                                "country" => op.c_shipcountry 
                            },
                            :po_number => op.c_po,
                            :sales_order_line_add => op.line_items.map do |li|
                                    {
                                        :item_ref => {:list_id => li.item.list_id},
                                        :desc => li.description,
                                        :quantity => li.qty,
                                        :amount =>  '%.2f' % li.amount
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
                        :customer_ref => {"list_id" => QBPush.customer.list_id},
                        :txn_date => QBPush.c_date,
                        :ship_address => {
                            "addr1" => QBPush.c_ship1,
                            "addr2" => QBPush.c_ship2,
                            "addr3" => QBPush.c_ship3,
                            "city" => QBPush.c_shipcity,
                            "state" => QBPush.c_shipstate,
                            "postal_code" => QBPush.c_shippostal,
                            "country" => QBPush.c_shipcountry 
                        },
                        :po_number => QBPush.c_po,
                        :sales_order_line_add => QBPush.line_items.map do |li|
                            {
                                :item_ref => {:list_id => li.item.list_id},
                                :desc => li.description,
                                :quantity => li.qty,
                                :amount => '%.2f' % li.amount
                            }
                        end
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
                invoice_data[:invoice_number] = qb_inv['ref_number']
                invoice_data[:c_total] = qb_inv['subtotal'].to_f

                if Order.exists?(c_po: qb_inv['po_number'])
                    orderupdate = Order.find_by(c_po: qb['po_number'])
                    # before updating, lets find out if it's neccessary by filtering by modified
                    if orderupdate.c_edit != qb_inv['edit_sequence']
                        invoice_data[:qb_sent_time] = Time.now
                        invoice_data[:send_to_qb] = false                        
                        orderupdate.update(invoice_data)
                    end

                         # START LINE ITEM MULTI/SINGLE                                   
                    if LineItem.exists?(txn_id: qb_inv['po_number'])
                        lineupdate = LineItem.where(txn_id: qb_inv['po_number'])
                        lineupdate.each do |li|
                            li.txn_id = qb_inv['txn_id']
                            li.save
                        end
                    end
                end
            end
 
        elsif !r['sales_order_ret'].blank? 
    	    qb_inv = r['sales_order_ret']
            invoice_data = {}
            invoice_data[:txn_id] = qb_inv['txn_id']
            # invoice_data[:qb_process] = false
            invoice_data[:c_edit] = qb_inv['edit_sequence']
            invoice_data[:invoice_number] = qb_inv['ref_number']
            invoice_data[:c_total] = qb_inv['subtotal'].to_f
            
            if Order.exists?(c_po: qb_inv['po_number'])

                orderupdate = Order.find_by(c_po: qb_inv['po_number'])
                # before updating, lets find out if it's neccessary by filtering by modified
                if orderupdate.c_edit != qb_inv['edit_sequence']
                    # invoice_data[:qb_sent_time] = Time.now
                    # invoice_data[:send_to_qb] = false
                    orderupdate.update(invoice_data)
                end

                # START LINE ITEM MULTI/SINGLE                                                   
                if LineItem.exists?(txn_id: qb_inv['po_number'])
                    lineupdate = LineItem.where(txn_id: qb_inv['po_number'])
                    lineupdate.each do |li|
                        li.txn_id = qb_inv['txn_id']
                        li.save
                    end
                end
            end
        end
        qbwc_log_create(WorkerName, 0, "complete", nil, qbwc_log_init(WorkerName), qbwc_log_end())
    	# Log.create(worker_name: "OrderPushWorker")


    end
end

