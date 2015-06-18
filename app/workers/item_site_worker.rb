require 'qbwc'

#   We will use this to pull site location data.

class ItemSiteWorker < QBWC::Worker
#    You cannot use iterator above Qbxml7.0, forced QBxml10.0
    def requests(job)
        {
            :inventory_site_query_rq => {
                :xml_attributes => { "requestID" =>"1" }
            }
        }
    end

    def handle_response(r, session, job, request, data)
#        We will loop through each item and insert it into the Site table.
#        <> ideally fix this so that it only updates, when a new item is added
        r['inventory_site_ret'].each do |qb_item|
#            Rails.logger.info("the start")
            site = {}
            site[:list_id] = qb_item['list_id']
            site[:edit_sq] = qb_item['edit_sequence']
            site[:name] = qb_item['name']
            site[:description] = qb_item['site_desc']
            site[:contact] = qb_item['contact']
            site[:phone] = qb_item['phone']
            site[:email] = qb_item['email']
            site[:address] = qb_item['site_address']['addr1']
            site[:address2] = qb_item['site_address']['addr2']
            site[:address3] = qb_item['site_address']['addr3']
            site[:address4] = qb_item['site_address']['addr4']
            site[:address5] = qb_item['site_address']['addr5']
            site[:city] = qb_item['site_address']['city']
            site[:state] = qb_item['site_address']['state']
            site[:postal] = qb_item['site_address']['postal_code']
             
            site = Site.find_by list_id: site[:list_id]
#             if site doesn't exist create the site record
             if site.blank?
                Site.create(site)
             end
        end
    end
end