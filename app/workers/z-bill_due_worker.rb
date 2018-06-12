require 'qbwc'


class BillDueWorker < QBWC::Worker

#    This worker will grab only active items, in the assembly section of QB.
#    We will use this to populate our item table, so that we can refernce orders and track inventory
    def requests(job)
        {
            :bill_query_rq => {
                :xml_attributes => { "requestID" =>"1", 'iterator'  => "Start" },
                :max_returned => 10,
                :txn_date_range_filter => { "from_txn_date" => "2015-10-01", "to_txn_date" => "2016-02-20"}
            }
        }
    end

    def handle_response(r, session, job, request, data)
        # handle_response will get customers in groups of 100. When this is 0, we're done.
        complete = r['xml_attributes']['iteratorRemainingCount'] == '0'

#        we will loop through each item and insert it into the Items table.
#        <> ideally fix this so that it only updates, when a new item is added
        r['bill_ret'].each do |qb_item|
            item_data = {}
            item_data[:txn_id] = qb_item['txn_id']
            item_data[:ref_number] = qb_item['ref_number']
            item_data[:name] = qb_item['vendor_ref']['full_name']
            item_data[:txn_date] = qb_item['txn_date']
            item_data[:due_date] = qb_item['due_date']
            item_data[:amount_due] = qb_item['amount_due'].to_f
            Rails.logger.info(item_data[:amount_due].class)
            Rails.logger.info(qb_item['amount_due'].class)
        #    binding.pry
                
#                create the item record
            unless qb_item['is_paid']
               item_data[:amount_due] = item_data[:amount_due].to_f
                Bill.create(item_data)
            else
                 Rails.logger.info("Customer info is the same")
            end
        
        end
    end
end