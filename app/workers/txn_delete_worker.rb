require 'qbwc'


class TxnDeleteWorker < QBWC::Worker

# Same thing, let's fine out the last time this was pulled, and decide if it's worth it
    if Log.exists?(worker_name: 'TxnDeleteWorker')

        LastUpdate = Log.where(worker_name: 'TxnDeleteWorker').order(created_at: :desc).limit(1)
        LastUpdate = LastUpdate[0][:created_at].strftime("%Y-%m-%d")
    else
        # This is preloading data based on no records in the log table
        LastUpdate = "2018-06-01"
    
    end

#    This worker will grab only active items, in the assembly section of QB.
#    We will use this to populate our item table, so that we can refernce orders and track inventory
    def requests(job)
        {
            :txn_deleted_query_rq => {
                :xml_attributes => { "requestID" =>"1"},
                :txn_del_type => ["Bill", "CreditMemo", "Invoice", "JournalEntry", "PurchaseOrder", "SalesOrder", "SalesReceipt"],
                :deleted_date_range_filter => {"from_deleted_date" => LastUpdate, "to_deleted_date" => Date.today + (1.0)}
            }
        }
    end

    def handle_response(r, session, job, request, data)
        # handle_response will get customers in groups of 100. When this is 0, we're done.
        complete = r['xml_attributes']['iteratorRemainingCount'] == '0'        
        # let's grab all inventory assembly items

        if r['txn_deleted_ret'].is_a? Array

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
            end
            #this is the end for the array of deleted list


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
        end
        Log.create(worker_name: "TxnDeleteWorker")

    end
end