require 'qbwc'
require 'concerns/qbwc_helper'
class TxnDeleteWorker < QBWC::Worker
    extend QbwcHelper
    
    #We will establish which worker this is. This will be used through-out.
    WorkerName = "TxnDeleteWorker"

#    This worker will grab only active items, in the assembly section of QB.
#    We will use this to populate our item table, so that we can refernce orders and track inventory
    def requests(job)
        {
            :txn_deleted_query_rq => {
                :xml_attributes => { "requestID" =>"1"},
                :txn_del_type => ["Bill", "CreditMemo", "Invoice", "JournalEntry", "PurchaseOrder", "SalesOrder", "SalesReceipt"],
                :deleted_date_range_filter => {"from_deleted_date" => qbwc_log_init(WorkerName), "to_deleted_date" => Date.today + (1.0)}
            }
        }
    end

    def handle_response(r, session, job, request, data)
        # handle_response will get customers in groups of 100. When this is 0, we're done.
        complete = r['xml_attributes']['iteratorRemainingCount'] == '0'        
        # let's grab all inventory assembly items
        if r['txn_deleted_ret'].nil? 
            # This will log if the data returned was empty and no updates occured, but it did run.
            qbwc_log_create(WorkerName, 0, "none", nil)            
        else

            if r['txn_deleted_ret'].is_a? Array
                i = 0
                # we will loop through each item and insert it into the Items table.
                r['txn_deleted_ret'].each do |qb_data|
                    if qb_data['txn_del_type']
                        table = 
                        case qb_data['txn_del_type']
                            when "JournalEntry"
                                Journal
                            when "Invoice"
                                Invoice
                            when "SalesOrder"
                                Order
                            when "SalesReceipt"
                                SalesReceipt
                            when "CreditMemo"
                                CreditMemo
                            else
                                nil
                        end  

                        if !table.nil?
                            delete_data = {}
                        
                            delete_data[:txn_id] = qb_data['txn_id']
                            delete_data[:deleted] = qb_data['time_deleted']

                            if table.exists?(txn_id: qb_data['txn_id'])
                                list_element = table.find_by(txn_id: qb_data['txn_id'])
                                list_element.update(delete_data)
                            end
                        end
                    end
                    i += 1
                end
                #this is the end for the array of deleted list

                qbwc_log_create(WorkerName, 0, "updates", i)

            # This is the start of just a single deleted list
            elsif !r['txn_deleted_ret'].blank? 
                qb_data = r['txn_deleted_ret']
                if qb_data['txn_del_type']
                    table = 
                    case qb_data['txn_del_type']
                        when "JournalEntry"
                            Journal
                        when "Invoice"
                            Invoice
                        when "SalesOrder"
                            Order
                        when "SalesReceipt"
                            SalesReceipt
                        when "CreditMemo"
                                CreditMemo
                        else
                            nil
                    end        

                    if !table.nil?
                        delete_data = {}
                    
                        delete_data[:txn_id] = qb_data['txn_id']
                        delete_data[:deleted] = qb_data['time_deleted']

                        if table.exists?(txn_id: qb_data['txn_id'])
                            list_element = table.find_by(txn_id: qb_data['txn_id'])
                            list_element.update(delete_data)
                        end
                    end
                end
            # End of the Accounts
                qbwc_log_create(WorkerName, 0, "updates", "1")
            end
            # this is the end of the non-array original sales order
            qbwc_log_create(WorkerName, 0, "complete", nil)
        end
    end
end