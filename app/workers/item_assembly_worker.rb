require 'qbwc'


class ItemAssemblyWorker < QBWC::Worker

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
#        Rails.logger.info ("---->Attempting Response")
            r['item_inventory_assembly_ret'].each do |qb_item|
            item_data = {}
            item_data[:list_id] = qb_item['list_id']
            item_data[:edit_sq] = qb_item['edit_sequence']
            item_data[:name] = qb_item['name']
            item_data[:description] = qb_item['full_name']
            item_data[:qty] = qb_item['quantity_on_hand'].to_f
#            @active = qb_item['is_active']
            
#            if @active == "t"
                Item.create(item_data)
#            end
        
        end
    
      
 end

    
end