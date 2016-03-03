require 'qbwc'


class ItemAssemblyWorker < QBWC::Worker

#    This worker will grab only active items, in the assembly section of QB.
#    We will use this to populate our item table, so that we can refernce orders and track inventory
    def requests(job)
        {
            :item_query_rq => {
                :xml_attributes => { "requestID" =>"1", 'iterator'  => "Start" },
                :max_returned => 500,
                :active_status => "ActiveOnly"
            }
        }
    end

    def handle_response(r, session, job, request, data)
        # handle_response will get customers in groups of 100. When this is 0, we're done.
        complete = r['xml_attributes']['iteratorRemainingCount'] == '0'

#        we will loop through each item and insert it into the Items table.
#        <> ideally fix this so that it only updates, when a new item is added
        r['item_inventory_assembly_ret'].each do |qb_item|
            item_data = {}
            item_data[:list_id] = qb_item['list_id']
            item_data[:edit_sq] = qb_item['edit_sequence']
            item_data[:name] = qb_item['name']
            item_data[:description] = qb_item['full_name']
            item_data[:qty] = qb_item['quantity_on_hand'].to_f
                
#                create the item record
        item = Item.find_by listid: item_data[:listid]
        if item.blank?
                Item.create(item_data)

        # Has the item in QB been updated? If so, we need to update in Rails  
        elsif item.updated_at < qb_item['time_modified']
            Item.update_all(customer_data)
        else
            Rails.logger.info("Item info is the same, no changes were made")
        end

        end
    end
end