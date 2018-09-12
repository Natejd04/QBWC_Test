require 'qbwc'
require 'qbwc_helpers/qbwc_helper'

class ListDeleteWorker < QBWC::Worker

# Same thing, let's fine out the last time this was pulled, and decide if it's worth it
    qbwc_log_init("ListDeleteWorker")

    # if Log.exists?(worker_name: 'ListDeleteWorker')

    #     LastUpdate = Log.where(worker_name: 'ListDeleteWorker').where(status: 'Completed').order(created_at: :desc).limit(1)
    #         if LastUpdate.nil? || LastUpdate.empty? 
    #             LastUpdate = Log.where(worker_name: 'ListDeleteWorker').order(created_at: :desc).limit(1)           
    #         end
    #     LastUpdate = LastUpdate[0][:created_at].strftime("%Y-%m-%d")
    # else
    #     # This is preloading data based on no records in the log table
    #     LastUpdate = "2018-06-01"
    
    # end

#    This worker will grab only active items, in the assembly section of QB.
#    We will use this to populate our item table, so that we can refernce orders and track inventory
    def requests(job)
        {
            :list_deleted_query_rq => {
                :xml_attributes => { "requestID" =>"1"},
                :list_del_type => ["Account", "Customer", "InventorySite", "ItemDiscount", "ItemFixedAsset", "ItemGroup", "ItemInventory", "ItemInventoryAssembly", "ItemNonInventory", "ItemOtherCharge", "ItemPayment", "ItemService", "ItemSubtotal", "Vendor"],
                :deleted_date_range_filter => {"from_deleted_date" => LastUpdate, "to_deleted_date" => Date.today + (1.0)}
            }
        }
    end

    def handle_response(r, session, job, request, data)
        # handle_response will get customers in groups of 100. When this is 0, we're done.
        complete = r['xml_attributes']['iteratorRemainingCount'] == '0'        
        # let's grab all inventory assembly items
        if r['list_deleted_ret'].nil? 
            # if it's true then we lay down a log update, saying not updated"
            # Need to add a column to log in order to state when the last one was run
            # UNLESS there is no trues, it goes with the last empty valued column
            Log.create(worker_name: "ListDeleteWorker", status: "No Changes")
        else
            # Data was fetched, and will execute
            # We need a way to say that there wasn't an error, and if so...mark complete.
            if r['list_deleted_ret'].is_a? Array
                i = 0
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
                                Log.create(worker_name: "ListDeleteWorker", status: "Updates", log_msg: "#{index} records were updated.")
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
                            Log.create(worker_name: "ListDeleteWorker", status: "Updates", log_msg: "One record was updated.")
                        end
                    end
                end
            # End of the Accounts
            end
        # Only if complete, put the complete one.
        Log.create(worker_name: "ListDeleteWorker", status: "Complete")
        end #closing of the if log statement

        

    end
end