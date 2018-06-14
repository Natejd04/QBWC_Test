require 'qbwc'

class SalesReceiptWorker < QBWC::Worker

    # production purposes only
    # :modified_date_range_filter => {"from_modified_date" => LastUpdate, "to_modified_date" => Date.today + (1.0)},
    # end production

    # Pre-load all data from 2017-Present, only if no data exists in the Log table.
    # If data exists in the Log table, we take the last pull date as a sort filter
    # We will limit this to 1, the most recent entry
    if Log.exists?(worker_name: "SalesReceiptWorker")

        LastUpdate = Log.where(worker_name: "SalesReceiptWorker").order(created_at: :desc).limit(1)
        LastUpdate = LastUpdate[0][:created_at].strftime("%Y-%m-%d")
    else
        # This is preloading data based on no records in the log table
        LastUpdate = "2017-12-01"
    
    end

    # This worker is going to be used to test. It will pre-load, with 2017 invoices.
    # This worker will update all invoices that were modified, to set date in request.
    # Currently set for no line-item import, that will be phase 2.
    
    def requests(job)
        {
            :sales_receipt_query_rq => {
                :modified_date_range_filter => {"from_modified_date" => LastUpdate, "to_modified_date" => Date.today + (1.0)},
                :include_line_items => true
            }
        }
    end

    def handle_response(r, session, job, request, data)
        # handle_response will get customers in groups of 100. When this is 0, we're done.
        # complete = r['xml_attributes']['iteratorRemainingCount'] == '0'

        # We will then loop through each invoice and create records.
        if r['sales_receipt_ret'].is_a? Array 

            r['sales_receipt_ret'].each do |qb_receipt|
                receipt_data = {}
                receipt_data[:txn_id] = qb_receipt['txn_id']
                receipt_data[:invoicenumber] = qb_receipt['ref_number']
                receipt_data[:qb_edit] = qb_receipt['edit_sequence']
                receipt_data[:txn_date] = qb_receipt['txn_date']
                
                if qb_receipt['currency_ref']
                    currency_ref = qb_receipt['currency_ref']['full_name']
                    receipt_data[:currency_ref] = qb_receipt['currency_ref']['full_name']
                    receipt_data[:exchange_rate] = qb_receipt['exchange_rate']
                    if currency_ref == "Canadian Dollar"
                        receipt_data[:subtotal] = (qb_receipt['subtotal'] * receipt_data[:exchange_rate])
                    else
                        receipt_data[:subtotal] = qb_receipt['subtotal']
                    end
                end

                receipt_data[:template] = qb_receipt['template_ref']['full_name']
                receipt_data[:qb_create] = qb_receipt['time_created']
                receipt_data[:qb_update] = qb_receipt['time_modified']

                if qb_receipt['po_number']
                    receipt_data[:po_number] = qb_receipt['po_number']
                end

                if qb_receipt['class_ref']
                    receipt_data[:class_name] = qb_receipt['class_ref']['full_name']
                end

                if qb_receipt['ship_date']
                    receipt_data[:ship_date] = qb_receipt['ship_date']
                end

                if qb_receipt['due_date']
                    receipt_data[:due_date] = qb_receipt['due_date']
                end

                if qb_receipt ['ship_method_ref']
                    receipt_data[:ship_via] = qb_receipt['ship_method_ref']['full_name']
                end

                if qb_receipt['customer_ref']
                    receipt_data[:customer_id] = Customer.find_by(listid: qb_receipt['customer_ref']['list_id']).id
                    receipt_data[:name] = qb_receipt['customer_ref']['full_name']
                end
              
                if qb_receipt['ship_address']
                    receipt_data[:ship1] = qb_receipt['ship_address']['addr1']
                    receipt_data[:ship2] = qb_receipt['ship_address']['addr2']
                    receipt_data[:ship3] = qb_receipt['ship_address']['addr3']
                    receipt_data[:ship4] = qb_receipt['ship_address']['addr4']
                    receipt_data[:ship5] = qb_receipt['ship_address']['addr5']
                    receipt_data[:shipcity] = qb_receipt['ship_address']['city']
                    receipt_data[:shipstate] = qb_receipt['ship_address']['state']
                    receipt_data[:shippostal] = qb_receipt['ship_address']['postal_code']
                    receipt_data[:shipcountry] = qb_receipt['ship_address']['country']
                end
                
                if qb_receipt['sales_rep_ref']
                    receipt_data[:sales_rep] = qb_receipt['sales_rep_ref']['full_name']
                end

                # We need to create the invoice first, so we can get it's ID.
                if SalesReceipt.exists?(txn_id: receipt_data[:txn_id])
                    receiptupdate = SalesReceipt.find_by(txn_id: receipt_data[:txn_id])
                        # before updating, lets find out if it's neccessary by filtering by modified
                        if receiptupdate.qb_edit != qb_receipt['edit_sequence']
                            receiptupdate.update(receipt_data)
                        end
                else
                    SalesReceipt.create(receipt_data)
                end

# ----------------> Start Line Item
                # Line items are recorded if they are an array
                if qb_receipt['sales_receipt_line_ret'].is_a? Array
                    
                    
                    qb_receipt['sales_receipt_line_ret'].each do |li|
                    
                        li_data = {}

                        # We need to match the lineitem with order id
                        # We just recorded it and could pull it via find.
                        li_data[:sales_receipt_id] = SalesReceipt.find_by(txn_id: qb_receipt['txn_id']).id

                        li_data[:txn_id] = li['txn_line_id']

                    #---->     # if li != {"xml_attributes"=>{}}
                        if li['item_ref']
                            # This line item has an item, let's find it
                            if Item.exists?(list_id: li['item_ref']['list_id'])
                                li_data[:item_id] = Item.find_by(list_id: li['item_ref']['list_id']).id
                            end
                        end
                    #---->   end
                        
                        if li['desc']
                            li_data[:description] = li['desc']
                        end

                        # Does the line item have a quantity
                        li_data[:qty] = li['quantity'].nil? ? nil : li['quantity'].to_i
                        # Does this li have an amount?
                        li_data[:amount] = li['amount'].nil? ? nil : li['amount'].to_f
                    
                        if li['inventory_site_ref']
                            if Site.exists?(list_id: li['inventory_site_ref']['list_id'])
                                li_data[:site_id] = Site.find_by(list_id: li['inventory_site_ref']['list_id']).id
                            end
                        end
                       
                        # Now we need to record these line items
                        if LineItem.exists?(txn_id: li['txn_line_id'])
                            lineitemupdate = LineItem.find_by(txn_id: li['txn_line_id'])
                            # Has this LineItem actually been modified?

                            if receiptupdate.qb_edit != qb_receipt['edit_sequence']
                                lineitemupdate.update(li_data)
                            end
                        else
                            LineItem.create(li_data)
                        end
                    end

                # we need this if the line item only has one entry.   
                elsif !qb_receipt['sales_receipt_line_ret'].blank? 
                    li_data = {}
                    li = qb_receipt['sales_receipt_line_ret']
                    # We need to match the lineitem with order id
                    # We just recorded it and could pull it via find.
                    li_data[:sales_receipt_id] = SalesReceipt.find_by(txn_id: qb_receipt['txn_id']).id

                    li_data[:txn_id] = li['txn_line_id']

                #---->     # if li != {"xml_attributes"=>{}}
                    if li['item_ref']
                        if Item.exists?(list_id: li['item_ref']['list_id'])
                            li_data[:item_id] = Item.find_by(list_id: li['item_ref']['list_id']).id
                        end
                    end
                #---->   end
                    
                    if li['desc']
                        li_data[:description] = li['desc']
                    end

                    # Does the line item have a quantity
                    li_data[:qty] = li['quantity'].nil? ? nil : li['quantity'].to_i
                    # Does this li have an amount?
                    li_data[:amount] = li['amount'].nil? ? nil : li['amount'].to_f
                    
                    if li['inventory_site_ref']
                        if Site.exists?(list_id: li['inventory_site_ref']['list_id'])
                            li_data[:site_id] = Site.find_by(list_id: li['inventory_site_ref']['list_id']).id
                        end
                    end
                   
                    # Now we need to record these line items
                    if LineItem.exists?(txn_id: li['txn_line_id'])
                        lineitemupdate = LineItem.find_by(txn_id: li['txn_line_id'])
                        # Has this LineItem actually been modified?

                        if receiptupdate.qb_edit != qb_receipt['edit_sequence']
                            lineitemupdate.update(li_data)
                        end
                    else
                        LineItem.create(li_data)
                    end
                end
    # ---------------> End Line Item     
            
            # This is the end of the original invoice each do
            end
  
        # If the obect wasn't an array and only one record was present we will record that
        # No loop or each process
        elsif !r['sales_receipt_ret'].blank? 
            qb_receipt = r['sales_receipt_ret']
               receipt_data = {}
                receipt_data[:txn_id] = qb_receipt['txn_id']
                receipt_data[:invoicenumber] = qb_receipt['ref_number']
                receipt_data[:qb_edit] = qb_receipt['edit_sequence']
                receipt_data[:txn_date] = qb_receipt['txn_date']
                
                if qb_receipt['currency_ref']
                    currency_ref = qb_receipt['currency_ref']['full_name']
                    receipt_data[:currency_ref] = qb_receipt['currency_ref']['full_name']
                    receipt_data[:exchange_rate] = qb_receipt['exchange_rate']
                    if currency_ref == "Canadian Dollar"
                        receipt_data[:subtotal] = (qb_receipt['subtotal'] * receipt_data[:exchange_rate])
                    else
                        receipt_data[:subtotal] = qb_receipt['subtotal']
                    end
                end

                receipt_data[:template] = qb_receipt['template_ref']['full_name']
                receipt_data[:qb_create] = qb_receipt['time_created']
                receipt_data[:qb_update] = qb_receipt['time_modified']

                if qb_receipt['po_number']
                    receipt_data[:po_number] = qb_receipt['po_number']
                end

                if qb_receipt['class_ref']
                    receipt_data[:class_name] = qb_receipt['class_ref']['full_name']
                end

                if qb_receipt['ship_date']
                    receipt_data[:ship_date] = qb_receipt['ship_date']
                end

                if qb_receipt['due_date']
                    receipt_data[:due_date] = qb_receipt['due_date']
                end

                if qb_receipt ['ship_method_ref']
                    receipt_data[:ship_via] = qb_receipt['ship_method_ref']['full_name']
                end

                if qb_receipt['customer_ref']
                    receipt_data[:customer_id] = Customer.find_by(listid: qb_receipt['customer_ref']['list_id']).id
                    receipt_data[:name] = qb_receipt['customer_ref']['full_name']
                end
              
                if qb_receipt['ship_address']
                    receipt_data[:ship1] = qb_receipt['ship_address']['addr1']
                    receipt_data[:ship2] = qb_receipt['ship_address']['addr2']
                    receipt_data[:ship3] = qb_receipt['ship_address']['addr3']
                    receipt_data[:ship4] = qb_receipt['ship_address']['addr4']
                    receipt_data[:ship5] = qb_receipt['ship_address']['addr5']
                    receipt_data[:shipcity] = qb_receipt['ship_address']['city']
                    receipt_data[:shipstate] = qb_receipt['ship_address']['state']
                    receipt_data[:shippostal] = qb_receipt['ship_address']['postal_code']
                    receipt_data[:shipcountry] = qb_receipt['ship_address']['country']
                end
                
                if qb_receipt['sales_rep_ref']
                    receipt_data[:sales_rep] = qb_receipt['sales_rep_ref']['full_name']
                end

                # We need to create the invoice first, so we can get it's ID.
                if SalesReceipt.exists?(txn_id: receipt_data[:txn_id])
                    receiptupdate = SalesReceipt.find_by(txn_id: receipt_data[:txn_id])
                        # before updating, lets find out if it's neccessary by filtering by modified
                        if receiptupdate.qb_edit != qb_receipt['edit_sequence']
                            receiptupdate.update(receipt_data)
                        end
                else
                    SalesReceipt.create(receipt_data)
                end

# ----------------> Start Line Item
            # Line items are recorded if they are an array
            if qb_receipt['sales_receipt_line_ret'].is_a? Array
                
                
                qb_receipt['sales_receipt_line_ret'].each do |li|
                
                    li_data = {}

                    # We need to match the lineitem with order id
                    # We just recorded it and could pull it via find.
                    li_data[:sales_receipt_id] = SalesReceipt.find_by(txn_id: qb_receipt['txn_id']).id

                    li_data[:txn_id] = li['txn_line_id']

                #---->     # if li != {"xml_attributes"=>{}}
                    if li['item_ref']
                        # This line item has an item, let's find it
                        if Item.exists?(list_id: li['item_ref']['list_id'])
                            li_data[:item_id] = Item.find_by(list_id: li['item_ref']['list_id']).id
                        end
                    end
                #---->   end
                    
                    if li['desc']
                        li_data[:description] = li['desc']
                    end

                    # Does the line item have a quantity
                    li_data[:qty] = li['quantity'].nil? ? nil : li['quantity'].to_i
                    # Does this li have an amount?
                    li_data[:amount] = li['amount'].nil? ? nil : li['amount'].to_f
                
                    if li['inventory_site_ref']
                        if Site.exists?(list_id: li['inventory_site_ref']['list_id'])
                            li_data[:site_id] = Site.find_by(list_id: li['inventory_site_ref']['list_id']).id
                        else
                            # insert the site list ID for unspecified.
                            # I am fairly positive this is required for model associations
                            li_data[:site_id] = Site.find_by(list_id: "80000005-1399305135")
                        end
                    end
                   
                    # Now we need to record these line items
                    if LineItem.exists?(txn_id: li['txn_line_id'])
                        lineitemupdate = LineItem.find_by(txn_id: li['txn_line_id'])
                        # Has this LineItem actually been modified?

                        if receiptupdate.qb_edit != qb_receipt['edit_sequence']
                            lineitemupdate.update(li_data)
                        end
                    else
                        LineItem.create(li_data)
                    end
                end

            # we need this if the line item only has one entry.   
            elsif !qb_receipt['sales_receipt_line_ret'].blank? 
                li_data = {}
                li = qb_receipt['sales_receipt_line_ret']
                # We need to match the lineitem with order id
                # We just recorded it and could pull it via find.
                li_data[:sales_receipt_id] = SalesReceipt.find_by(txn_id: qb_receipt['txn_id']).id

                li_data[:txn_id] = li['txn_line_id']

                if li['item_ref']
                    if Item.exists?(list_id: li['item_ref']['list_id'])
                        li_data[:item_id] = Item.find_by(list_id: li['item_ref']['list_id']).id
                    end
                end
                
                if li['desc']
                    li_data[:description] = li['desc']
                end

                # Does the line item have a quantity
                li_data[:qty] = li['quantity'].nil? ? nil : li['quantity'].to_i
                # Does this li have an amount?
                li_data[:amount] = li['amount'].nil? ? nil : li['amount'].to_f
                
                if li['inventory_site_ref']
                    if Site.exists?(list_id: li['inventory_site_ref']['list_id'])
                        li_data[:site_id] = Site.find_by(list_id: li['inventory_site_ref']['list_id']).id
                    else
                        # insert the site list ID for unspecified.
                        # I am fairly positive this is required for model associations
                        li_data[:site_id] = Site.find_by(list_id: "80000005-1399305135")
                    end
                end
               
                # Now we need to record these line items
                if LineItem.exists?(txn_id: li['txn_line_id'])
                    lineitemupdate = LineItem.find_by(txn_id: li['txn_line_id'])
                    # Has this LineItem actually been modified?

                    if receiptupdate.qb_edit != qb_receipt['edit_sequence']
                        lineitemupdate.update(li_data)
                    end
                else
                    LineItem.create(li_data)
                end
            end
    # ---------------> End Line Item    


        end
        # this is the end of the non-array original invoice

    # let's record that this worker was ran, so that it's timestamped in logs
    # Moved the log creating to be within the handle response incase the response errors, I don't want a log.
    Log.create(worker_name: "SalesReceiptWorker")

    end
end