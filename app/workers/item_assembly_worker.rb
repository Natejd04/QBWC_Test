require 'qbwc'
require 'concerns/qbwc_helper'

class ItemAssemblyWorker < QBWC::Worker
    include QbwcHelper
    
    
    #We will establish which worker this is. This will be used through-out.
    WorkerName = "ItemAssemblyWorker"

    def requests(job)
        {
            :item_query_rq => {
                :xml_attributes => { "requestID" =>"1", 'iterator'  => "Start" },
                :max_returned => 1000, #required
                :from_modified_date => qbwc_log_init(WorkerName),
                :to_modified_date => qbwc_log_end(),
                :owner_id => 0
            }
        }
    end

    def handle_response(r, session, job, request, data)
        # handle_response will get customers in groups of 100. When this is 0, we're done.
        complete = r['xml_attributes']['iteratorRemainingCount'] == '0'

        if r['item_inventory_assembly_ret'].nil? 
            # This will log if the data returned was empty and no updates occured, but it did run.
            qbwc_log_create(WorkerName, 1, "none", "No assembly items were updated", qbwc_log_init(WorkerName), qbwc_log_end())            
        else

            # let's grab all inventory assembly items
            if r['item_inventory_assembly_ret'].is_a? Array

                # we will loop through each item and insert it into the Items table.
                r['item_inventory_assembly_ret'].each do |qb_item|
                    item_data = {}
                    item_data[:list_id] = qb_item['list_id']
                    item_data[:edit_sq] = qb_item['edit_sequence']
                    item_data[:name] = qb_item['full_name']
                    item_data[:item_type] = "Inventory Assembly"

                    # Start Loop for Owner ID 0
                    if qb_item['data_ext_ret'].is_a? Array
                        qb_item['data_ext_ret'].each do |li|
                            if li['data_ext_name'] == "UPC"
                                if li['data_ext_value'] 
                                    item_data[:upc] = li['data_ext_value']
                                end
                            end
                            if li['data_ext_name'] == "Code"
                                if li['data_ext_value'] 
                                    item_data[:code] = li['data_ext_value']
                                end
                            end
                        end
                    elsif !qb_item['data_ext_ret'].blank? 
                        li = qb_item['data_ext_ret']
                        if li['data_ext_name'] == "UPC"
                            if li['data_ext_value'] 
                                item_data[:upc] = li['data_ext_value']
                            end
                        end
                        if li['data_ext_name'] == "Code"
                            if li['data_ext_value'] 
                                item_data[:code] = li['data_ext_value']
                            end
                        end
                    end



                    if qb_item['income_account_ref']
                        if Account.exists?(list_id: qb_item['income_account_ref']['list_id'])
                            item_data[:account_id] = Account.find_by(list_id: qb_item['income_account_ref']['list_id']).id
                        end
                    end
                    
                    if qb_item['sales_and_purchase']
                        item_data[:description] = qb_item['sales_and_purchase']['full_name']
                    end

                    if qb_item['unit_of_measure_set_ref']
                        item_data[:unit] = qb_item['unit_of_measure_set_ref']['full_name']
                    end
                        
                    if Item.exists?(list_id: qb_item['list_id'])
                        itemupdate = Item.find_by(list_id: qb_item['list_id'])
                        # # before updating, lets find out if it's neccessary by filtering by modified
                        if itemupdate.edit_sq != qb_item['edit_sequence']
                            itemupdate.update(item_data)
                       end
                    else
                        Item.create(item_data)
                    end
                end

            # This is if there is only 1 item update
            elsif !r['item_inventory_assembly_ret'].blank? 
                qb_item = r['item_inventory_assembly_ret']
                item_data = {}
                item_data[:list_id] = qb_item['list_id']
                item_data[:edit_sq] = qb_item['edit_sequence']
                item_data[:name] = qb_item['full_name']
                item_data[:item_type] = "Inventory Assembly"

                # Start Loop for Owner ID 0
                if qb_item['data_ext_ret'].is_a? Array
                    qb_item['data_ext_ret'].each do |li|
                        if li['data_ext_name'] == "UPC"
                            if li['data_ext_value'] 
                                item_data[:upc] = li['data_ext_value']
                            end
                        end
                        if li['data_ext_name'] == "Code"
                            if li['data_ext_value'] 
                                item_data[:code] = li['data_ext_value']
                            end
                        end
                    end
                elsif !qb_item['data_ext_ret'].blank? 
                    li = qb_item['data_ext_ret']
                    if li['data_ext_name'] == "UPC"
                        if li['data_ext_value'] 
                            item_data[:upc] = li['data_ext_value']
                        end
                    end
                    if li['data_ext_name'] == "Code"
                        if li['data_ext_value'] 
                            item_data[:code] = li['data_ext_value']
                        end
                    end
                end
                
                if qb_item['sales_and_purchase']
                    item_data[:description] = qb_item['sales_and_purchase']['full_name']
                end

                if qb_item['income_account_ref']
                    if Account.exists?(list_id: qb_item['income_account_ref']['list_id'])
                        item_data[:account_id] = Account.find_by(list_id: qb_item['income_account_ref']['list_id']).id
                    end
                end

                if qb_item['unit_of_measure_set_ref']
                    item_data[:unit] = qb_item['unit_of_measure_set_ref']['full_name']
                end
                    
                if Item.exists?(list_id: qb_item['list_id'])
                    itemupdate = Item.find_by(list_id: qb_item['list_id'])
                    # # before updating, lets find out if it's neccessary by filtering by modified
                    if itemupdate.edit_sq != qb_item['edit_sequence']
                        itemupdate.update(item_data)
                  end
                else
                    Item.create(item_data)
                end
            
            end
            # End of the Assembly items
            qbwc_log_create(WorkerName, 1, "updates", "Assembly items were created/updated", qbwc_log_init(WorkerName), qbwc_log_end())
        # This is the end of the empty statement
        end

        if r['item_service_ret'].nil?
            # This will log if the data returned was empty and no updates occured, but it did run.
            qbwc_log_create(WorkerName, 1, "none", "No service items were updated", qbwc_log_init(WorkerName), qbwc_log_end())            
        else
            # Now lets grab service items
            if r['item_service_ret'].is_a? Array

                # we will loop through each item and insert it into the Items table.
                r['item_service_ret'].each do |qb_item|
                    item_data = {}
                    item_data[:list_id] = qb_item['list_id']
                    item_data[:edit_sq] = qb_item['edit_sequence']
                    item_data[:name] = qb_item['full_name']
                    item_data[:item_type] = "Service"

                    if qb_item['bar_code_value']                    
                        item_data[:code] = qb_item['bar_code_value']
                    end
                    
                    if qb_item['sales_and_purchase']
                        item_data[:description] = qb_item['sales_and_purchase']['full_name']
                        if Account.exists?(list_id: qb_item['sales_and_purchase']['account_ref']['list_id'])
                            item_data[:account_id] = Account.find_by(list_id: qb_item['sales_and_purchase']['account_ref']['list_id']).id
                        end

                    end

                    if qb_item['unit_of_measure_set_ref']
                        item_data[:unit] = qb_item['unit_of_measure_set_ref']['full_name']
                    end
                        
                    if Item.exists?(list_id: qb_item['list_id'])
                        itemupdate = Item.find_by(list_id: qb_item['list_id'])
                        # before updating, lets find out if it's neccessary by filtering by modified
                        if itemupdate.edit_sq != qb_item['edit_sequence']
                            itemupdate.update(item_data)
                        end
                    else
                        Item.create(item_data)
                    end
                end

            elsif !r['item_service_ret'].blank? 
                qb_item = r['item_service_ret'] 
                item_data = {}
                item_data[:list_id] = qb_item['list_id']
                item_data[:edit_sq] = qb_item['edit_sequence']
                item_data[:name] = qb_item['full_name']
                item_data[:item_type] = "Service"

                if qb_item['bar_code_value']                    
                    item_data[:code] = qb_item['bar_code_value']
                end
                
                if qb_item['sales_and_purchase']
                    item_data[:description] = qb_item['sales_and_purchase']['full_name']
                    if Account.exists?(list_id: qb_item['sales_and_purchase']['account_ref']['list_id'])
                        item_data[:account_id] = Account.find_by(list_id: qb_item['sales_and_purchase']['account_ref']['list_id']).id
                    end
                end

                if qb_item['unit_of_measure_set_ref']
                    item_data[:unit] = qb_item['unit_of_measure_set_ref']['full_name']
                end
                    
                if Item.exists?(list_id: qb_item['list_id'])
                    itemupdate = Item.find_by(list_id: qb_item['list_id'])
                    # before updating, lets find out if it's neccessary by filtering by modified
                    if itemupdate.edit_sq != qb_item['edit_sequence']
                        itemupdate.update(item_data)
                    end
                else
                    Item.create(item_data)
                end

            end
            # end of the service items
            qbwc_log_create(WorkerName, 1, "updates", "Service items were created/updated", qbwc_log_init(WorkerName), qbwc_log_end())
        end

        if r['item_non_inventory_ret'].nil?
            # This will log if the data returned was empty and no updates occured, but it did run.
            qbwc_log_create(WorkerName, 1, "none", "no non inventory items were changed/updated", qbwc_log_init(WorkerName), qbwc_log_end())            
        else    
            # Now lets grab non-inventory part items
            if r['item_non_inventory_ret'].is_a? Array

                # we will loop through each item and insert it into the Items table.
                r['item_non_inventory_ret'].each do |qb_item|
                    item_data = {}
                    item_data[:list_id] = qb_item['list_id']
                    item_data[:edit_sq] = qb_item['edit_sequence']
                    item_data[:name] = qb_item['full_name']
                    item_data[:item_type] = "Non-Inventory Part"

                    # Start Loop for Owner ID 0
                    if qb_item['data_ext_ret'].is_a? Array
                        qb_item['data_ext_ret'].each do |li|
                            if li['data_ext_name'] == "UPC"
                                if li['data_ext_value'] 
                                    item_data[:upc] = li['data_ext_value']
                                end
                            end
                            if li['data_ext_name'] == "Code"
                                if li['data_ext_value'] 
                                    item_data[:code] = li['data_ext_value']
                                end
                            end
                        end
                    elsif !qb_item['data_ext_ret'].blank? 
                        li = qb_item['data_ext_ret']
                        if li['data_ext_name'] == "UPC"
                            if li['data_ext_value'] 
                                item_data[:upc] = li['data_ext_value']
                            end
                        end
                        if li['data_ext_name'] == "Code"
                            if li['data_ext_value'] 
                                item_data[:code] = li['data_ext_value']
                            end
                        end
                    end
                    
                    if qb_item['sales_or_purchase']
                        if Account.exists?(list_id: qb_item['sales_or_purchase']['account_ref']['list_id'])
                            item_data[:account_id] = Account.find_by(list_id: qb_item['sales_or_purchase']['account_ref']['list_id']).id
                        end
                    end

                    if qb_item['sales_and_purchase']
                        item_data[:description] = qb_item['sales_and_purchase']['full_name']
                    end

                    if qb_item['unit_of_measure_set_ref']
                        item_data[:unit] = qb_item['unit_of_measure_set_ref']['full_name']
                    end
                        
                    if Item.exists?(list_id: qb_item['list_id'])
                        itemupdate = Item.find_by(list_id: qb_item['list_id'])
                        # # before updating, lets find out if it's neccessary by filtering by modified
                        if itemupdate.edit_sq != qb_item['edit_sequence']
                            itemupdate.update(item_data)
                        end
                    else
                        Item.create(item_data)
                    end
                end

            elsif !r['item_non_inventory_ret'].blank?
                qb_item = r['item_non_inventory_ret']
                item_data = {}
                item_data[:list_id] = qb_item['list_id']
                item_data[:edit_sq] = qb_item['edit_sequence']
                item_data[:name] = qb_item['full_name']
                item_data[:item_type] = "Non-Inventory Part"
                
                # Start Loop for Owner ID 0
                if qb_item['data_ext_ret'].is_a? Array
                    qb_item['data_ext_ret'].each do |li|
                        if li['data_ext_name'] == "UPC"
                            if li['data_ext_value'] 
                                item_data[:upc] = li['data_ext_value']
                            end
                        end
                        if li['data_ext_name'] == "Code"
                            if li['data_ext_value'] 
                                item_data[:code] = li['data_ext_value']
                            end
                        end
                    end
                elsif !qb_item['data_ext_ret'].blank? 
                    li = qb_item['data_ext_ret']
                    if li['data_ext_name'] == "UPC"
                        if li['data_ext_value'] 
                            item_data[:upc] = li['data_ext_value']
                        end
                    end
                    if li['data_ext_name'] == "Code"
                        if li['data_ext_value'] 
                            item_data[:code] = li['data_ext_value']
                        end
                    end
                end
                
                if qb_item['sales_or_purchase']
                    if Account.exists?(list_id: qb_item['sales_or_purchase']['account_ref']['list_id'])
                        item_data[:account_id] = Account.find_by(list_id: qb_item['sales_or_purchase']['account_ref']['list_id']).id
                    end
                end

                if qb_item['sales_and_purchase']
                    item_data[:description] = qb_item['sales_and_purchase']['full_name']
                end

                if qb_item['unit_of_measure_set_ref']
                    item_data[:unit] = qb_item['unit_of_measure_set_ref']['full_name']
                end
                    
                if Item.exists?(list_id: qb_item['list_id'])
                    itemupdate = Item.find_by(list_id: qb_item['list_id'])
                    # # before updating, lets find out if it's neccessary by filtering by modified
                    if itemupdate.edit_sq != qb_item['edit_sequence']
                        itemupdate.update(item_data)
                    end
                else
                    Item.create(item_data)
                end
            end
            # end of the non-inventory part items
                    
        qbwc_log_create(WorkerName, 1, "updates", "Non-Inventory items were created/updated", qbwc_log_init(WorkerName), qbwc_log_end())
        end

        if r['item_other_charge_ret'].nil?
            # This will log if the data returned was empty and no updates occured, but it did run.
            qbwc_log_create(WorkerName, 1, "none", "No other charge group items were updated", qbwc_log_init(WorkerName), qbwc_log_end())            
        else 
            # Now lets grab the item other charge group
            if r['item_other_charge_ret'].is_a? Array

                # we will loop through each item and insert it into the Items table.
                r['item_other_charge_ret'].each do |qb_item|
                    item_data = {}
                    item_data[:list_id] = qb_item['list_id']
                    item_data[:edit_sq] = qb_item['edit_sequence']
                    item_data[:name] = qb_item['full_name']
                    item_data[:item_type] = "Other Charge"

                    # Start Loop for Owner ID 0
                    if qb_item['data_ext_ret'].is_a? Array
                        qb_item['data_ext_ret'].each do |li|
                            if li['data_ext_name'] == "UPC"
                                if li['data_ext_value'] 
                                    item_data[:upc] = li['data_ext_value']
                                end
                            end
                            if li['data_ext_name'] == "Code"
                                if li['data_ext_value'] 
                                    item_data[:code] = li['data_ext_value']
                                end
                            end
                        end
                    elsif !qb_item['data_ext_ret'].blank? 
                        li = qb_item['data_ext_ret']
                        if li['data_ext_name'] == "UPC"
                            if li['data_ext_value'] 
                                item_data[:upc] = li['data_ext_value']
                            end
                        end
                        if li['data_ext_name'] == "Code"
                            if li['data_ext_value'] 
                                item_data[:code] = li['data_ext_value']
                            end
                        end
                    end

                    if qb_item['sales_or_purchase']
                        if Account.exists?(list_id: qb_item['sales_or_purchase']['account_ref']['list_id'])
                            item_data[:account_id] = Account.find_by(list_id: qb_item['sales_or_purchase']['account_ref']['list_id']).id
                        end
                    end
                    
                    if qb_item['sales_and_purchase']
                        item_data[:description] = qb_item['sales_and_purchase']['sales_desc']
                    end

              
                    if Item.exists?(list_id: qb_item['list_id'])
                        itemupdate = Item.find_by(list_id: qb_item['list_id'])
                        # # before updating, lets find out if it's neccessary by filtering by modified
                        if itemupdate.edit_sq != qb_item['edit_sequence']
                            itemupdate.update(item_data)
                        end
                    else
                        Item.create(item_data)
                    end
                end
            
            elsif !r['item_other_charge_ret'].blank?
                qb_item = r['item_other_charge_ret']
                item_data = {}
                item_data[:list_id] = qb_item['list_id']
                item_data[:edit_sq] = qb_item['edit_sequence']
                item_data[:name] = qb_item['full_name']
                item_data[:item_type] = "Other Charge"

                # Start Loop for Owner ID 0
                if qb_item['data_ext_ret'].is_a? Array
                    qb_item['data_ext_ret'].each do |li|
                        if li['data_ext_name'] == "UPC"
                            if li['data_ext_value'] 
                                item_data[:upc] = li['data_ext_value']
                            end
                        end
                        if li['data_ext_name'] == "Code"
                            if li['data_ext_value'] 
                                item_data[:code] = li['data_ext_value']
                            end
                        end
                    end
                elsif !qb_item['data_ext_ret'].blank? 
                    li = qb_item['data_ext_ret']
                    if li['data_ext_name'] == "UPC"
                        if li['data_ext_value'] 
                            item_data[:upc] = li['data_ext_value']
                        end
                    end
                    if li['data_ext_name'] == "Code"
                        if li['data_ext_value'] 
                            item_data[:code] = li['data_ext_value']
                        end
                    end
                end
                
                if qb_item['sales_or_purchase']
                    if Account.exists?(list_id: qb_item['sales_or_purchase']['account_ref']['list_id'])
                        item_data[:account_id] = Account.find_by(list_id: qb_item['sales_or_purchase']['account_ref']['list_id']).id
                    end
                end

                if qb_item['sales_and_purchase']
                    item_data[:description] = qb_item['sales_and_purchase']['sales_desc']
                end
                    
                if Item.exists?(list_id: qb_item['list_id'])
                    itemupdate = Item.find_by(list_id: qb_item['list_id'])
                    # # before updating, lets find out if it's neccessary by filtering by modified
                    if itemupdate.edit_sq != qb_item['edit_sequence']
                        itemupdate.update(item_data)
                    end
                else
                    Item.create(item_data)
                end
            end
            # end of the other charge group items
        qbwc_log_create(WorkerName, 1, "updates", "Other Charge group items were created/updated", qbwc_log_init(WorkerName), qbwc_log_end())
        end

        if r['item_inventory_ret'].nil?
            # This will log if the data returned was empty and no updates occured, but it did run.
            qbwc_log_create(WorkerName, 1, "none", "no inventory part items updated", qbwc_log_init(WorkerName), qbwc_log_end())            
        else 
            # Now lets grab the inventory part group
            if r['item_inventory_ret'].is_a? Array

                # we will loop through each item and insert it into the Items table.
                r['item_inventory_ret'].each do |qb_item|
                    item_data = {}
                    item_data[:list_id] = qb_item['list_id']
                    item_data[:edit_sq] = qb_item['edit_sequence']
                    item_data[:name] = qb_item['full_name']
                    item_data[:item_type] = "Inventory Part"

                    if qb_item['bar_code_value']                    
                        item_data[:code] = qb_item['bar_code_value']
                    end
                    
                    if qb_item['purchase_desc']
                        item_data[:description] = qb_item['purchase_desc']
                    end

                    if qb_item['income_account_ref']
                        if Account.exists?(list_id: qb_item['income_account_ref']['list_id'])
                            item_data[:account_id] = Account.find_by(list_id: qb_item['income_account_ref']['list_id']).id
                        end
                    end

                    if qb_item['unit_of_measure_set_ref']
                        item_data[:unit] = qb_item['unit_of_measure_set_ref']['full_name']
                    end
                        
                    if Item.exists?(list_id: qb_item['list_id'])
                        itemupdate = Item.find_by(list_id: qb_item['list_id'])
                        # before updating, lets find out if it's neccessary by filtering by modified
                        if itemupdate.edit_sq != qb_item['edit_sequence']
                            itemupdate.update(item_data)
                        end
                    else
                        Item.create(item_data)
                    end
                end

            elsif !r['item_inventory_ret'].blank?
                qb_item = r['item_inventory_ret']
                item_data = {}
                item_data[:list_id] = qb_item['list_id']
                item_data[:edit_sq] = qb_item['edit_sequence']
                item_data[:name] = qb_item['full_name']
                item_data[:item_type] = "Inventory Part"

                if qb_item['bar_code_value']                    
                    item_data[:code] = qb_item['bar_code_value']
                end
                
                if qb_item['purchase_desc']
                    item_data[:description] = qb_item['purchase_desc']
                end

                if qb_item['income_account_ref']
                    if Account.exists?(list_id: qb_item['income_account_ref']['list_id'])
                        item_data[:account_id] = Account.find_by(list_id: qb_item['income_account_ref']['list_id']).id
                    end
                end

                if qb_item['unit_of_measure_set_ref']
                    item_data[:unit] = qb_item['unit_of_measure_set_ref']['full_name']
                end
                    
                if Item.exists?(list_id: qb_item['list_id'])
                 itemupdate = Item.find_by(list_id: qb_item['list_id'])
                    # before updating, lets find out if it's neccessary by filtering by modified
                    if itemupdate.edit_sq != qb_item['edit_sequence']
                        itemupdate.update(item_data)
                    end
                else
                    Item.create(item_data)
                end

            end
            # end of the inventory part group
        qbwc_log_create(WorkerName, 1, "updates", "Inventory Part Group items were created/updated", qbwc_log_init(WorkerName), qbwc_log_end())
        end        

        if r['item_discount_ret'].nil?
            # This will log if the data returned was empty and no updates occured, but it did run.
            qbwc_log_create(WorkerName, 1, "none", "no discount items updated", qbwc_log_init(WorkerName), qbwc_log_end())            
        else 
            # Now lets grab the item discount group
            if r['item_discount_ret'].is_a? Array

                # we will loop through each item and insert it into the Items table.
                r['item_discount_ret'].each do |qb_item|
                    item_data = {}
                    item_data[:list_id] = qb_item['list_id']
                    item_data[:edit_sq] = qb_item['edit_sequence']
                    item_data[:name] = qb_item['full_name']
                    item_data[:item_type] = "Discount"

                    if qb_item['bar_code_value']                    
                        item_data[:code] = qb_item['bar_code_value']
                    end
                    
                    if qb_item['account_ref']
                        if Account.exists?(list_id: qb_item['account_ref']['list_id'])
                            item_data[:account_id] = Account.find_by(list_id: qb_item['account_ref']['list_id']).id
                        end
                    end

                    if qb_item['item_desc']
                        item_data[:description] = qb_item['item_desc']
                    end
             
                    if Item.exists?(list_id: qb_item['list_id'])
                        itemupdate = Item.find_by(list_id: qb_item['list_id'])
                        # before updating, lets find out if it's neccessary by filtering by modified
                        if itemupdate.edit_sq != qb_item['edit_sequence']
                            itemupdate.update(item_data)
                        end
                    else
                        Item.create(item_data)
                    end
                end

            elsif !r['item_discount_ret'].blank?
                qb_item = r['item_discount_ret']
                item_data = {}
                item_data[:list_id] = qb_item['list_id']
                item_data[:edit_sq] = qb_item['edit_sequence']
                item_data[:name] = qb_item['full_name']
                item_data[:item_type] = "Discount"

                if qb_item['bar_code_value']                    
                    item_data[:code] = qb_item['bar_code_value']
                end
                
                if qb_item['account_ref']
                    if Account.exists?(list_id: qb_item['account_ref']['list_id'])
                        item_data[:account_id] = Account.find_by(list_id: qb_item['account_ref']['list_id']).id
                    end
                end

                if qb_item['item_desc']
                    item_data[:description] = qb_item['item_desc']
                end
         
                if Item.exists?(list_id: qb_item['list_id'])
                    itemupdate = Item.find_by(list_id: qb_item['list_id'])
                    # before updating, lets find out if it's neccessary by filtering by modified
                    if itemupdate.edit_sq != qb_item['edit_sequence']
                        itemupdate.update(item_data)
                    end
                else
                    Item.create(item_data)
                end
            end
            # end of the discount group 
            qbwc_log_create(WorkerName, 1, "updates", "Discount group items were created/updated", qbwc_log_init(WorkerName), qbwc_log_end())        
        end

        if r['item_subtotal_ret'].nil?
            # This will log if the data returned was empty and no updates occured, but it did run.
            qbwc_log_create(WorkerName, 1, "none", "no subtotal items updated", qbwc_log_init(WorkerName), qbwc_log_end())            
        else 
            # Now lets grab the subtotal group
            if r['item_subtotal_ret'].is_a? Array

                # we will loop through each item and insert it into the Items table.
                r['item_subtotal_ret'].each do |qb_item|
                    item_data = {}
                    item_data[:list_id] = qb_item['list_id']
                    item_data[:edit_sq] = qb_item['edit_sequence']
                    item_data[:name] = qb_item['name']
                    item_data[:item_type] = "Subtotal"

                    if qb_item['bar_code_value']                    
                        item_data[:code] = qb_item['bar_code_value']
                    end
                    
                    if qb_item['item_desc']
                        item_data[:description] = qb_item['item_desc']
                    end
             
                    if Item.exists?(list_id: qb_item['list_id'])
                        itemupdate = Item.find_by(list_id: qb_item['list_id'])
                        # before updating, lets find out if it's neccessary by filtering by modified
                        if itemupdate.edit_sq != qb_item['edit_sequence']
                            itemupdate.update(item_data)
                        end
                    else
                        Item.create(item_data)
                    end
                end

            elsif !r['item_subtotal_ret'].blank?
                qb_item = r['item_subtotal_ret']
                item_data = {}
                item_data[:list_id] = qb_item['list_id']
                item_data[:edit_sq] = qb_item['edit_sequence']
                item_data[:name] = qb_item['name']
                item_data[:item_type] = "Subtotal"

                if qb_item['bar_code_value']                    
                    item_data[:code] = qb_item['bar_code_value']
                end
                
                if qb_item['item_desc']
                    item_data[:description] = qb_item['item_desc']
                end
         
                if Item.exists?(list_id: qb_item['list_id'])
                    itemupdate = Item.find_by(list_id: qb_item['list_id'])
                    # before updating, lets find out if it's neccessary by filtering by modified
                    if itemupdate.edit_sq != qb_item['edit_sequence']
                        itemupdate.update(item_data)
                    end
                else
                    Item.create(item_data)
                end
            end
            # end of the subtotal group 
            qbwc_log_create(WorkerName, 1, "updates", "Subtotal items were created/updated", qbwc_log_init(WorkerName), qbwc_log_end())
        end

        if r['item_sales_tax_ret'].nil?
            # This will log if the data returned was empty and no updates occured, but it did run.
            qbwc_log_create(WorkerName, 1, "none", "no sales tax items updated", qbwc_log_init(WorkerName), qbwc_log_end())            
        else 
             # Now lets grab the sales tax group
            if r['item_sales_tax_ret'].is_a? Array

                # we will loop through each item and insert it into the Items table.
                r['item_sales_tax_ret'].each do |qb_item|
                    item_data = {}
                    item_data[:list_id] = qb_item['list_id']
                    item_data[:edit_sq] = qb_item['edit_sequence']
                    item_data[:name] = qb_item['name']
                    item_data[:item_type] = "Sales Tax"

                    if qb_item['bar_code_value']                    
                        item_data[:code] = qb_item['bar_code_value']
                    end
                    
                    if qb_item['item_desc']
                        item_data[:description] = qb_item['item_desc']
                    end
             
                    if Item.exists?(list_id: qb_item['list_id'])
                        itemupdate = Item.find_by(list_id: qb_item['list_id'])
                        # before updating, lets find out if it's neccessary by filtering by modified
                        if itemupdate.edit_sq != qb_item['edit_sequence']
                            itemupdate.update(item_data)
                        end
                    else
                        Item.create(item_data)
                    end
                end

            elsif !r['item_sales_tax_ret'].blank?
                qb_item = r['item_sales_tax_ret']
                item_data = {}
                item_data[:list_id] = qb_item['list_id']
                item_data[:edit_sq] = qb_item['edit_sequence']
                item_data[:name] = qb_item['name']
                item_data[:item_type] = "Sales Tax"

                if qb_item['bar_code_value']                    
                    item_data[:code] = qb_item['bar_code_value']
                end
                
                if qb_item['item_desc']
                    item_data[:description] = qb_item['item_desc']
                end
         
                if Item.exists?(list_id: qb_item['list_id'])
                    itemupdate = Item.find_by(list_id: qb_item['list_id'])
                    # before updating, lets find out if it's neccessary by filtering by modified
                    if itemupdate.edit_sq != qb_item['edit_sequence']
                        itemupdate.update(item_data)
                    end
                else
                    Item.create(item_data)
                end
                # end of the discount group 
                qbwc_log_create(WorkerName, 1, "updates", "Sales tax items were created/updated", qbwc_log_init(WorkerName), qbwc_log_end())         
            end
            qbwc_log_create(WorkerName, 0, "complete", nil, qbwc_log_init(WorkerName), qbwc_log_end())
            # This is the end of the empty statement
        end
    end
end