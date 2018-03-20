require 'qbwc'


class ItemAssemblyWorker < QBWC::Worker

# Same thing, let's fine out the last time this was pulled, and decide if it's worth it
    if Log.exists?(worker_name: 'ItemAssemblyWorker')

        LastUpdate = Log.where(worker_name: 'ItemAssemblyWorker').order(created_at: :desc).limit(1)
        LastUpdate = LastUpdate[0][:created_at].strftime("%Y-%m-%d")
    else
        # This is preloading data based on no records in the log table
        LastUpdate = "2018-02-20"
    
    end

#    This worker will grab only active items, in the assembly section of QB.
#    We will use this to populate our item table, so that we can refernce orders and track inventory
    def requests(job)
        {
            :item_query_rq => {
                :xml_attributes => { "requestID" =>"1", 'iterator'  => "Start" },
                :max_returned => 500,
                :active_status => "ActiveOnly",
                :from_modified_date => LastUpdate,
                :to_modified_date => Date.today + (1.0)
            }
        }
    end

    def handle_response(r, session, job, request, data)
        # handle_response will get customers in groups of 100. When this is 0, we're done.
        complete = r['xml_attributes']['iteratorRemainingCount'] == '0'

        # let's grab all inventory assembly items
        if r['item_inventory_assembly_ret']

            # we will loop through each item and insert it into the Items table.
            r['item_inventory_assembly_ret'].each do |qb_item|
                item_data = {}
                item_data[:list_id] = qb_item['list_id']
                item_data[:edit_sq] = qb_item['edit_sequence']
                item_data[:name] = qb_item['full_name']
                item_data[:item_type] = "Inventory Assembly"

                if qb_item['bar_code_value']                    
                    item_data[:code] = qb_item['bar_code_value']
                end
                
                if qb_item['sales_and_purchase']
                    item_data[:description] = qb_item['sales_and_purchase']['full_name']
                end

                if qb_item['unit_of_measure_set_ref']
                    item_data[:unit] = qb_item['unit_of_measure_set_ref']['full_name']
                end
                    
                if Item.exists?(list_id: item_data['list_id'])
                    itemupdate = Item.find_by(list_id: site['list_id'])
                    # before updating, lets find out if it's neccessary by filtering by modified
                    if itemupdate.edit_sq != qb_item['edit_sequence']
                        itemupdate.update(item_data)
                    end
                else
                    Item.create(item_data)
                end
            end
        end
        # End of the Assembly items
        
        # Now lets grab service items
        if r['item_service_ret']

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
                end

                if qb_item['unit_of_measure_set_ref']
                    item_data[:unit] = qb_item['unit_of_measure_set_ref']['full_name']
                end
                    
                if Item.exists?(list_id: item_data['list_id'])
                    itemupdate = Item.find_by(list_id: site['list_id'])
                    # before updating, lets find out if it's neccessary by filtering by modified
                    if itemupdate.edit_sq != qb_item['edit_sequence']
                        itemupdate.update(item_data)
                    end
                else
                    Item.create(item_data)
                end
            end
        end
        # end of the service items

        # Now lets grab non-inventory part items
        if r['item_non_inventory_ret']

            # we will loop through each item and insert it into the Items table.
            r['item_non_inventory_ret'].each do |qb_item|
                item_data = {}
                item_data[:list_id] = qb_item['list_id']
                item_data[:edit_sq] = qb_item['edit_sequence']
                item_data[:name] = qb_item['full_name']
                item_data[:item_type] = "Non-Inventory Part"

                if qb_item['bar_code_value']                    
                    item_data[:code] = qb_item['bar_code_value']
                end
                
                if qb_item['sales_and_purchase']
                    item_data[:description] = qb_item['sales_and_purchase']['full_name']
                end

                if qb_item['unit_of_measure_set_ref']
                    item_data[:unit] = qb_item['unit_of_measure_set_ref']['full_name']
                end
                    
                if Item.exists?(list_id: item_data['list_id'])
                    itemupdate = Item.find_by(list_id: site['list_id'])
                    # before updating, lets find out if it's neccessary by filtering by modified
                    if itemupdate.edit_sq != qb_item['edit_sequence']
                        itemupdate.update(item_data)
                    end
                else
                    Item.create(item_data)
                end
            end
        end
        # end of the non-inventory part items

        # Now lets grab the item other charge group
        if r['item_other_charge_ret']

            # we will loop through each item and insert it into the Items table.
            r['item_other_charge_ret'].each do |qb_item|
                item_data = {}
                item_data[:list_id] = qb_item['list_id']
                item_data[:edit_sq] = qb_item['edit_sequence']
                item_data[:name] = qb_item['full_name']
                item_data[:item_type] = "Other Charge"

                if qb_item['bar_code_value']                    
                    item_data[:code] = qb_item['bar_code_value']
                end
                
                if qb_item['sales_and_purchase']
                    item_data[:description] = qb_item['sales_and_purchase']['full_name']
                end

                if qb_item['unit_of_measure_set_ref']
                    item_data[:unit] = qb_item['unit_of_measure_set_ref']['full_name']
                end
                    
                if Item.exists?(list_id: item_data['list_id'])
                    itemupdate = Item.find_by(list_id: site['list_id'])
                    # before updating, lets find out if it's neccessary by filtering by modified
                    if itemupdate.edit_sq != qb_item['edit_sequence']
                        itemupdate.update(item_data)
                    end
                else
                    Item.create(item_data)
                end
            end
        end
        # end of the other charge group items

        # Now lets grab the inventory part group
        if r['item_inventory_ret']

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

                if qb_item['unit_of_measure_set_ref']
                    item_data[:unit] = qb_item['unit_of_measure_set_ref']['full_name']
                end
                    
                if Item.exists?(list_id: item_data['list_id'])
                    itemupdate = Item.find_by(list_id: site['list_id'])
                    # before updating, lets find out if it's neccessary by filtering by modified
                    if itemupdate.edit_sq != qb_item['edit_sequence']
                        itemupdate.update(item_data)
                    end
                else
                    Item.create(item_data)
                end
            end
        end
        # end of the inventory part group

        # Now lets grab the item discount group
        if r['item_discount_ret']

            # we will loop through each item and insert it into the Items table.
            r['item_discount_ret'].each do |qb_item|
                item_data = {}
                item_data[:list_id] = qb_item['list_id']
                item_data[:edit_sq] = qb_item['edit_sequence']
                item_data[:name] = qb_item['full_name']
                item_data[:item_type] = "Dscount"

                if qb_item['bar_code_value']                    
                    item_data[:code] = qb_item['bar_code_value']
                end
                
                if qb_item['item_desc']
                    item_data[:description] = qb_item['item_desc']
                end
         
                if Item.exists?(list_id: item_data['list_id'])
                    itemupdate = Item.find_by(list_id: site['list_id'])
                    # before updating, lets find out if it's neccessary by filtering by modified
                    if itemupdate.edit_sq != qb_item['edit_sequence']
                        itemupdate.update(item_data)
                    end
                else
                    Item.create(item_data)
                end
            end
        end
        # end of the discount group 

    end
end