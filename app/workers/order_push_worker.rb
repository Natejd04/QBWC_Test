require 'qbwc'
require 'concerns/qbwc_helper'
class OrderPushWorker < QBWC::Worker
    include QbwcHelper

    #Was asked to send Amazon DF orders direct to invoice. This naming convention is misleading
    WorkerName = "OrderPushWorker"

    def requests(job)    
        { :invoice_add_rq => {
            :xml_attributes => {"requestID" => "1"}
            }
        }
        qbsend = Order.where(send_to_qb: true, qb_process: true, qb_sent_time: nil)
        if !qbsend.blank?           
            qbsend.map do |op|
                    { :invoice_add_rq => {
                        :xml_attributes => { "requestID" =>"2"},
                        :invoice_add => {
                            :customer_ref => {"list_id" => op.customer.list_id},
                            :class_ref => {"full_name" => op.c_class},
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
                            :due_date => op.c_ship.strftime("%Y-%m-%d"),
                            :ship_date => op.c_ship.strftime("%Y-%m-%d"),
                            :invoice_line_add => op.line_items.map do |li|
                                    {                                    
                                        :item_ref => {:list_id => li.item.list_id},
                                        :desc => li.description,
                                        :quantity => li.qty,
                                        :class_ref => {:full_name => op.c_class},
                                        :amount =>  '%.2f' % li.amount,
                                        :inventory_site_ref => {:list_id => li.site.list_id}
                                    }
                                end
                        }
                    }
                }
            end      

        elsif qbsend.is_a? Array
            {
                :invoice_add_rq => {
                    :xml_attributes => { "requestID" =>"1"},
                    :invoice_add => {
                        :customer_ref => {"list_id" => qbsend.customer.list_id},
                        :class_ref => {"full_name" => qbsend.c_class},
                        :txn_date => qbsend.c_date,
                        :ship_address => {
                            "addr1" => qbsend.c_ship1,
                            "addr2" => qbsend.c_ship2,
                            "addr3" => qbsend.c_ship3,                            
                            "city" => qbsend.c_shipcity,
                            "state" => qbsend.c_shipstate,
                            "postal_code" => qbsend.c_shippostal,
                            "country" => qbsend.c_shipcountry 
                        },
                        :po_number => qbsend.c_po,
                        :due_date => op.c_ship.strftime("%Y-%m-%d"),
                        :ship_date => op.c_ship.strftime("%Y-%m-%d"),
                        :invoice_line_add => qbsend.line_items.map do |li|
                            {
                                :item_ref => {:list_id => li.item.list_id},
                                :desc => li.description,
                                :quantity => li.qty,
                                :class_ref => {:full_name => qbsend.c_class},
                                :amount => '%.2f' % li.amount,
                                :inventory_site_ref => {:list_id => li.site.list_id}
                            }
                        end
                    }
                }
            }
        end
            
    end

    def handle_response(r, session, job, request, data)
        
        if r['invoice_ret'].is_a? Array
            r['invoice_ret'].each do |qb_inv|
                invoice_data = {}
                invoice_data[:txn_id] = qb_inv['txn_id']
                invoice_data[:invoice_number] = qb_inv['txn_number']
                invoice_data[:c_invoiced] = true
                invoice_data[:qb_process] = false
                invoice_data[:c_edit] = qb_inv['edit_sequence']
                invoice_data[:invoice_number] = qb_inv['ref_number']
                invoice_data[:c_total] = qb_inv['subtotal'].to_f
                invoice_data[:qb_sent_time] = Time.now()

                if Order.exists?(c_po: qb_inv['po_number'])
                    orderupdate = Order.find_by(c_po: qb_inv['po_number'])
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
 
        elsif !r['invoice_ret'].blank? 
            qb_inv = r['invoice_ret']
            invoice_data = {}
            invoice_data[:txn_id] = qb_inv['txn_id']
            invoice_data[:invoice_number] = qb_inv['txn_number']
            invoice_data[:c_invoiced] = "qbwc_closed"
            invoice_data[:qb_process] = false
            invoice_data[:c_edit] = qb_inv['edit_sequence']
            invoice_data[:invoice_number] = qb_inv['ref_number']
            invoice_data[:c_total] = qb_inv['subtotal'].to_f
            invoice_data[:qb_sent_time] = Time.now()
            
            if Order.exists?(c_po: qb_inv['po_number'])

                orderupdate = Order.find_by(c_po: qb_inv['po_number'])
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
        qbwc_log_create(WorkerName, 0, "complete", nil, qbwc_log_init(WorkerName), qbwc_log_end())
        # Log.create(worker_name: "OrderPushWorker")

    end
# qbsend = Order.where(send_to_qb: true, qb_process: true, qb_sent_time: nil)
end





