require 'qbwc'

#    <> This Worker isn't functioning, for some reason. Parsing XML error?

class ItemSiteWorker < QBWC::Worker

    def requests(job)
        {
            :inventory_site_query_rq => {
                :xml_attributes => { "requestID" =>"1", 'iterator'  => "Start" },
                :max_returned => 100
            }
        }
    end

    def handle_response(r, session, job, request, data)
        # handle_response will get customers in groups of 100. When this is 0, we're done.
        complete = r['xml_attributes']['iteratorRemainingCount'] == '0'

#        we will loop through each item and insert it into the Items table.
#        <> ideally fix this so that it only updates, when a new item is added
        r['inventory_site_query_rs'].each do |qb_item|
#            Rails.logger.info("the start")
            item = {}
#            item_data[:list_id] = qb_item['list_id']
#            item_data[:edit_sq] = qb_item['edit_sequence']
#            item_data[:name] = qb_item['name']
#            item_data[:description] = qb_item['full_name']
#            item_data[:qty] = qb_item['quantity_on_hand'].to_f
             item = qb_item['txn_id']   
##                create the item record
#                Item.create(item_data)
        
#        
        end
    end
end