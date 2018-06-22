require 'qbwc'

#   We will use this to pull site location data.

class InvSiteWorker < QBWC::Worker
#    You cannot use iterator above Qbxml7.0, forced QBxml10.0
    if Log.exists?(worker_name: 'InvSiteWorker')

        LastUpdate = Log.where(worker_name: 'InvSiteWorker').order(created_at: :desc).limit(1)
        LastUpdate = LastUpdate[0][:created_at].strftime("%Y-%m-%d")
    else
        # This is preloading data based on no records in the log table
        LastUpdate = "2014-01-01"
    
    end

    def requests(job)
        {
            :inventory_site_query_rq => {
                :active_status => "All",
                :from_modified_date => LastUpdate,
                :to_modified_date => Date.today + (1.0)
                
            }
        }
    end

    def handle_response(r, session, job, request, data)
#        We will loop through each item and insert it into the Site table.
#        <> ideally fix this so that it only updates, when a new item is added
        if r['inventory_site_ret'].is_a? Array

            r['inventory_site_ret'].each do |qb_item|

    #           assign all the values to an array
                site = {}
                site[:list_id] = qb_item['list_id']
                site[:edit_sq] = qb_item['edit_sequence']
                site[:name] = qb_item['name']
                site[:description] = qb_item['site_desc']
                site[:contact] = qb_item['contact']
                site[:phone] = qb_item['phone']
                site[:email] = qb_item['email']

                if qb_item['is_active'] == true
                    site[:active] = true
                else
                    site[:active] = false
                end

                if qb_item['site_address']
                    site[:address] = qb_item['site_address']['addr1']
                    site[:address2] = qb_item['site_address']['addr2']
                    site[:address3] = qb_item['site_address']['addr3']
                    site[:address4] = qb_item['site_address']['addr4']
                    site[:address5] = qb_item['site_address']['addr5']
                    site[:city] = qb_item['site_address']['city']
                    site[:state] = qb_item['site_address']['state']
                    site[:postal] = qb_item['site_address']['postal_code']
                end

                if Site.exists?(list_id: qb_item['list_id'])
                    siteupdate = Site.find_by(list_id: qb_item['list_id'])
                    # before updating, lets find out if it's neccessary by filtering by modified
                    if siteupdate.edit_sq != qb_item['edit_sequence']
                        siteupdate.update(site)
                    end
                else
                    Site.create(site)
                end
            end
            Log.create(worker_name: "InvSiteWorker")

        # We need this if there is not an array of sites
        elsif !r['inventory_site_ret'].blank? 
            qb_item =  r['inventory_site_ret']
            site = {}
            site[:list_id] = qb_item['list_id']
            site[:edit_sq] = qb_item['edit_sequence']
            site[:name] = qb_item['name']
            site[:description] = qb_item['site_desc']
            site[:contact] = qb_item['contact']
            site[:phone] = qb_item['phone']
            site[:email] = qb_item['email']

            if qb_item['is_active'] == true
                site[:active] = true
            else
                site[:active] = false
            end

            if qb_item['site_address']
                site[:address] = qb_item['site_address']['addr1']
                site[:address2] = qb_item['site_address']['addr2']
                site[:address3] = qb_item['site_address']['addr3']
                site[:address4] = qb_item['site_address']['addr4']
                site[:address5] = qb_item['site_address']['addr5']
                site[:city] = qb_item['site_address']['city']
                site[:state] = qb_item['site_address']['state']
                site[:postal] = qb_item['site_address']['postal_code']
            end

            if Site.exists?(list_id: qb_item['list_id'])
                siteupdate = Site.find_by(list_id: qb_item['list_id'])
                # before updating, lets find out if it's neccessary by filtering by modified
                if siteupdate.edit_sq != qb_item['edit_sequence']
                    siteupdate.update(site)
                end
            else
                Site.create(site)
            end
            Log.create(worker_name: "InvSiteWorker")
        end
    end
end