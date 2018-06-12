require 'qbwc'

#   We will use this to pull site location data.

class InvQtyWorker < QBWC::Worker
#    You cannot use iterator above Qbxml7.0, forced QBxml10.0
    def requests(job)
        {
            :item_sites_query_rq => {
                :xml_attributes => { "requestID" =>"1" }
            }
        }
    end

    def handle_response(r, session, job, request, data)
#        We will loop through each item and insert it into the Site table.
#        <> ideally fix this so that it only updates, when a new item is added
        r['item_sites_ret'].each do |qb_item|

#           assign all the values to an array
            invsite = {}
#            if qb_item['inventory_site_ref']['list_id']
            assembly_ref = qb_item['item_inventory_assembly_ref']
            site_ref = qb_item['inventory_site_ref']
            
            if !assembly_ref.nil? && !assembly_ref.empty? 
                if !site_ref.nil? && !site_ref.empty?
                    item_id = qb_item['item_inventory_assembly_ref']['list_id']
                    
                    item = Item.find_by(list_id: item_id)
                    if item.present?
                        site = Site.find_by(list_id: qb_item['inventory_site_ref']['list_id'])
                        invsite = item.site_inventories.build(site_id: site.id)
#                        invsite['item_id'] = Item.find_by(list_id: item_id).id

#                        site_id = qb_item['inventory_site_ref']['list_id']
#                        invsite['site_id'] = Site.find_by(list_id: site_id).id
                        invsite.qty = qb_item['quantity_on_hand'].to_f
                        invsite.qty_so = qb_item['quantity_on_sales_orders'].to_f
                        invsite.save
    #             <> need to make this so it won't add unless new sites.
#                        SiteInventory.create(invsite)
                    end
                end
             end
        end
    end
end