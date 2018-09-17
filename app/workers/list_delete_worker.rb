require 'qbwc'
require 'concerns/qbwc_helper'
class ListDeleteWorker < QBWC::Worker
    extend QbwcHelper
    extend QbwcLogCreate

    #We will establish which worker this is. This will be used through-out.
    WorkerName = "ListDeleteWorker"

#    This worker will grab only active items, in the assembly section of QB.
#    We will use this to populate our item table, so that we can refernce orders and track inventory
    def requests(job)
        {
            :list_deleted_query_rq => {
                :xml_attributes => { "requestID" =>"1"},
                :list_del_type => ["Account", "Customer", "InventorySite", "ItemDiscount", "ItemFixedAsset", "ItemGroup", "ItemInventory", "ItemInventoryAssembly", "ItemNonInventory", "ItemOtherCharge", "ItemPayment", "ItemService", "ItemSubtotal", "Vendor"],
                :deleted_date_range_filter => {"from_deleted_date" => qbwc_log_init(WorkerName), "to_deleted_date" => Date.today + (1.0)}
            }
        }
    end

    def handle_response(r, session, job, request, data)
        # handle_response will get customers in groups of 100. When this is 0, we're done.
        complete = r['xml_attributes']['iteratorRemainingCount'] == '0'        
        
        if r['list_deleted_ret'].nil? 
            # This will log if the data returned was empty and no updates occured, but it did run.
            qbwc_log_create(WorkerName, 0, "none", nil)            
        else
            # Data was fetched, and will execute
            # We need a way to say that there wasn't an error, and if so...mark complete.
            
            # let's grab all inventory assembly items
            if r['list_deleted_ret'].is_a? Array                
                # we will loop through each item and insert it into the Items table.
                r['list_deleted_ret'].each_with_index do |qb_data, index|
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
                            else
                                nil
                        end                
                        if !table.nil?
                            delete_data = {}
                        
                            delete_data[:list_id] = qb_data['list_id']
                            delete_data[:deleted] = qb_data['time_deleted']

                            if table.exists?(list_id: qb_data['list_id'])
                                list_element = table.find_by(list_id: qb_data['list_id'])
                                list_element.update(delete_data)
                                # This will record how many updates were made.
                                qbwc_log_create(WorkerName, 0, "updates", index)
                            end
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
                        when "Site"
                            Site
                        when "ItemDiscount", "ItemFixedAsset", "ItemGroup", "ItemInventory", "ItemInventoryAssembly", "ItemNonInventory", "ItemOtherCharge", "ItemPayment", "ItemService", "ItemSubtotal"
                            Item
                        when "Vendor"
                            Vendor
                    else
                            nil
                    end                
                    
                    if !table.nil?
                        delete_data = {}
                    
                        delete_data[:list_id] = qb_data['list_id']
                        delete_data[:deleted] = qb_data['time_deleted']

                        if table.exists?(list_id: qb_data['list_id'])
                            list_element = table.find_by(list_id: qb_data['list_id'])
                            list_element.update(delete_data)
                            qbwc_log_create(WorkerName, 0, "updates", "1")                            
                        end
                    end
                end
            # End of the Accounts
            end
        # Only if complete, put the complete one.
        qbwc_log_create(WorkerName, 0, "complete", nil)
        end #closing of the if log statement

        

    end
end