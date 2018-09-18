require 'qbwc'
require 'concerns/qbwc_helper'
#   We will use this to pull site location data.

class InvSiteWorker < QBWC::Worker
    include QbwcHelper
    
    #We will establish which worker this is. This will be used through-out.
    WorkerName = "InvSiteWorker"

    def requests(job)
        {
            :inventory_site_query_rq => {
                :active_status => "All",
                :from_modified_date => qbwc_log_init(WorkerName),
                :to_modified_date => qbwc_log_end()
                
            }
        }
    end

    def handle_response(r, session, job, request, data)
#        We will loop through each item and insert it into the Site table.
#        <> ideally fix this so that it only updates, when a new item is added
        if r['account_ret'].nil? 
            # This will log if the data returned was empty and no updates occured, but it did run.
            qbwc_log_create(WorkerName, 0, "none", nil, qbwc_log_init(WorkerName), qbwc_log_end())            
        else

            if r['inventory_site_ret'].is_a? Array
                i = 0
                r['inventory_site_ret'].each_with_index do |qb_item, index|

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
                    i += 1
                end
                qbwc_log_create(WorkerName, 0, "updates", i.to_s, qbwc_log_init(WorkerName), qbwc_log_end())

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
                qbwc_log_create(WorkerName, 0, "updates", "1", qbwc_log_init(WorkerName), qbwc_log_end())
            end
            qbwc_log_create(WorkerName, 0, "complete", nil, qbwc_log_init(WorkerName), qbwc_log_end())
        # This is the end of the empty statement
        end
    end
end