require 'qbwc'

#   We will use this to pull site location data.

class InvSiteWorker < QBWC::Worker
#    You cannot use iterator above Qbxml7.0, forced QBxml10.0
    def requests(job)
        {
            :inventory_site_query_rq => {
                :xml_attributes => { "requestID" =>"1"},
                :from_modified_date => Site.order("updated_at").last[:updated_at].strftime("%Y-%m-%d"),
                :to_modified_date => DateTime.now.strftime("%Y-%m-%d")
            }
        }
    end

    def handle_response(r, session, job, request, data)
#        We will loop through each item and insert it into the Site table.
#        <> ideally fix this so that it only updates, when a new item is added
    
    if r['inventory_site_ret']
    
        r['inventory_site_ret'].each do |qb_item|
            
#           assign all the values to an array
            site_data = {}
        site_data[:list_id] = qb_item['list_id']
            site_data[:edit_sq] = qb_item['edit_sequence']
            site_data[:name] = qb_item['name']
            site_data[:description] = qb_item['site_desc']
            site_data[:contact] = qb_item['contact']
            site_data[:phone] = qb_item['phone']
            site_data[:email] = qb_item['email']
            if qb_item['site_address']
                site_data[:address] = qb_item['site_address']['addr1']
                site_data[:address2] = qb_item['site_address']['addr2']
                site_data[:address3] = qb_item['site_address']['addr3']
                site_data[:address4] = qb_item['site_address']['addr4']
                site_data[:address5] = qb_item['site_address']['addr5']
                site_data[:city] = qb_item['site_address']['city']
                site_data[:state] = qb_item['site_address']['state']
                site_data[:postal] = qb_item['site_address']['postal_code']
            end
            
            site_ref = Site.find_by list_id: site_data[:list_id]

        if site_ref.blank?
                Site.create(site_data)

        # Has the item in QB been updated? If so, we need to update in Rails  
        elsif site_ref.updated_at < qb_item['time_modified']
            site_ref.update(site_data)
        else
            Rails.logger.info("Item info is the same, no changes were made")
        end

        end

    end
    end
end