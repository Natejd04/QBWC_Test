require 'qbwc'


class ListDeleteWorker < QBWC::Worker

# Same thing, let's fine out the last time this was pulled, and decide if it's worth it
    if Log.exists?(worker_name: 'ListDeleteWorker')

        LastUpdate = Log.where(worker_name: 'ListDeleteWorker').order(created_at: :desc).limit(1)
        LastUpdate = LastUpdate[0][:created_at].strftime("%Y-%m-%d")
    else
        # This is preloading data based on no records in the log table
        LastUpdate = "2017-12-01"
    
    end

#    This worker will grab only active items, in the assembly section of QB.
#    We will use this to populate our item table, so that we can refernce orders and track inventory
    def requests(job)
        {
            :list_deleted_query_rq => {
                :list_del_type => { "Account", "Customer", "InventorySite", "ItemDiscount", "ItemFixedAsset", "ItemGroup", "ItemInventory", "ItemInventoryAssembly", "ItemNonInventory", 
                "ItemOtherCharge", "ItemPayment", "ItemService", "ItemSubtotal", "Vendor"},
                :from_deleted_date => LastUpdate,
                :to_deleted_date => Date.today + (1.0)
            }
        }
    end

    def handle_response(r, session, job, request, data)
        # handle_response will get customers in groups of 100. When this is 0, we're done.
        # complete = r['xml_attributes']['iteratorRemainingCount'] == '0'
        # binding.pry
        # let's grab all inventory assembly items
        if r['list_deleted_ret'].is_a? Array

            # we will loop through each item and insert it into the Items table.
            r['list_deleted_ret'].each do |qb_data|
                if qb_data['list_del_type']
                    table = 
                    case qb_data['list_del_type']
                        when "Account"
                            Account
                        when "Customer"
                            Customer
                        when "InventorySite"
                            Site
                        when "ItemDiscount", "ItemFixedAsset", "ItemGroup", "ItemInventory", "ItemInventoryAssembly", "ItemNonInventory", "ItemOtherCharge", "ItemPayment", "ItemService", "ItemSubtotal"
                            Item
                        when "Vendor"
                            Vendor
                    end                

                    delete_data = {}
                
                    delete_data[:list_id] = qb_data['list_id']
                    delete_data[:deleted] = qb_data['time_deleted']

                    if table.exists?(list_id: qb_data['list_id'])
                        list_element = table.find_by(list_id: qb_data['list_id'])
                        list_element.update(delete_data)
                    end
                end
            end
            #this is the end for the array of deleted list


        # This is the start of just a single deleted list
        elsif !r['list_deleted_ret'].blank? 
            qb_data = r['list_deleted_ret']
            if qb_data['list_del_type']
                table = 
                case qb_data['list_del_type']
                    when "Account"
                        Account
                    when "Customer"
                        Customer
                    when "InventorySite"
                        Site
                    when "ItemDiscount", "ItemFixedAsset", "ItemGroup", "ItemInventory", "ItemInventoryAssembly", "ItemNonInventory", "ItemOtherCharge", "ItemPayment", "ItemService", "ItemSubtotal"
                        Item
                    when "Vendor"
                        Vendor
                end                

                delete_data = {}
            
                delete_data[:list_id] = qb_data['list_id']
                delete_data[:deleted] = qb_data['time_deleted']

                if table.exists?(list_id: qb_data['list_id'])
                    list_element = table.find_by(list_id: qb_data['list_id'])
                    list_element.update(delete_data)
                end
            end
        # End of the Accounts
        end
        Log.create(worker_name: "ListDeleteWorker")

    end
end