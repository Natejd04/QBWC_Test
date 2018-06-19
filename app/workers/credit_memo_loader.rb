require 'qbwc'

class CreditMemoLoader < QBWC::Worker

    # production purposes only
    # :modified_date_range_filter => {"from_modified_date" => LastUpdate, "to_modified_date" => Date.today + (1.0)},
    # end production

    # Pre-load all data from 2017-Present, only if no data exists in the Log table.
    # If data exists in the Log table, we take the last pull date as a sort filter
    # We will limit this to 1, the most recent entry
    if Log.exists?(worker_name: 'CreditMemoLoader')

        LastUpdate = Log.where(worker_name: "CreditMemoLoader").order(created_at: :desc).limit(1)
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
            :credit_memo_query_rq => {
                :modified_date_range_filter => {"from_modified_date" => LastUpdate, "to_modified_date" => Date.today + (1.0)},
                :include_line_items => true
            }
        }
    end

    def handle_response(r, session, job, request, data)
        # handle_response will get customers in groups of 100. When this is 0, we're done.
        # complete = r['xml_attributes']['iteratorRemainingCount'] == '0'

        # We will then loop through each invoice and create records.
        if r['credit_memo_ret'].is_a? Array 

            r['credit_memo_ret'].each do |qb_inv|
                invoice_data = {}
                invoice_data[:txn_id] = qb_inv['txn_id']
                invoice_data[:c_invoicenumber] = qb_inv['ref_number']
                invoice_data[:c_edit] = qb_inv['edit_sequence']
                invoice_data[:c_date] = qb_inv['txn_date']
                invoice_data[:c_balance_due] = qb_inv['balance_remaining_in_home_currency']
                

                if qb_inv['currency_ref']
                    currency_ref = qb_inv['currency_ref']['full_name']
                    invoice_data[:currency_ref] = qb_inv['currency_ref']['full_name']
                    invoice_data[:exchange_rate] = qb_inv['exchange_rate']
                    if currency_ref == "Canadian Dollar"
                        invoice_data[:c_subtotal] = (qb_inv['subtotal'] * invoice_data[:exchange_rate])
                    else
                        invoice_data[:c_subtotal] = qb_inv['subtotal']
                    end
                end

                invoice_data[:c_template] = qb_inv['template_ref']['full_name']
                invoice_data[:c_qbcreate] = qb_inv['time_created']
                invoice_data[:c_qbupdate] = qb_inv['time_modified']

                if qb_inv['po_number']
                    invoice_data[:c_po] = qb_inv['po_number']
                end

                if qb_inv['class_ref']
                    invoice_data[:c_class] = qb_inv['class_ref']['full_name']
                end

                if qb_inv['ship_date']
                    invoice_data[:c_ship] = qb_inv['ship_date']
                end

                if qb_inv['due_date']
                    invoice_data[:c_duedate] = qb_inv['due_date']
                end

                if qb_inv ['ship_method_ref']
                    invoice_data[:c_via] = qb_inv['ship_method_ref']['full_name']
                end

                if qb_inv['customer_ref']
                    invoice_data[:customer_id] = Customer.find_by(list_id: qb_inv['customer_ref']['list_id']).id
                    invoice_data[:c_name] = qb_inv['customer_ref']['full_name']
                end
              
                if qb_inv['ship_address']
                    invoice_data[:c_ship1] = qb_inv['ship_address']['addr1']
                    invoice_data[:c_ship2] = qb_inv['ship_address']['addr2']
                    invoice_data[:c_ship3] = qb_inv['ship_address']['addr3']
                    invoice_data[:c_ship4] = qb_inv['ship_address']['addr4']
                    invoice_data[:c_ship5] = qb_inv['ship_address']['addr5']
                    invoice_data[:c_shipcity] = qb_inv['ship_address']['city']
                    invoice_data[:c_shipstate] = qb_inv['ship_address']['state']
                    invoice_data[:c_shippostal] = qb_inv['ship_address']['postal_code']
                    invoice_data[:c_shipcountry] = qb_inv['ship_address']['country']
                end
                
                if qb_inv['sales_rep_ref']
                    invoice_data[:c_rep] = qb_inv['sales_rep_ref']['full_name']
                end

                # We need to create the invoice first, so we can get it's ID.
                if CreditMemo.exists?(txn_id: invoice_data[:txn_id])
                    invoiceupdate = CreditMemo.find_by(txn_id: invoice_data[:txn_id])
                        # before updating, lets find out if it's neccessary by filtering by modified
                        if invoiceupdate.c_edit != qb_inv['edit_sequence']
                            invoiceupdate.update(invoice_data)
                        end
                else
                    CreditMemo.create(invoice_data)
                end

# ----------------> Start Line Item
                # Line items are recorded if they are an array
                if qb_inv['credit_memo_line_ret'].is_a? Array
                    
                    
                    qb_inv['credit_memo_line_ret'].each do |li|
                    
                        li_data = {}

                        # We need to match the lineitem with order id
                        # We just recorded it and could pull it via find.
                        li_data[:credit_memo_id] = CreditMemo.find_by(txn_id: qb_inv['txn_id']).id

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

                        if qb_inv['exchange_rate'] != 1.0 and !li['amount'].nil?
                            li_data[:homecurrency_amount] = (li_data[:amount] * qb_inv['exchange_rate'].to_f)
                        else
                            li_data[:homecurrency_amount] = li_data[:amount]
                        end

                        if li['inventory_site_ref']
                            if Site.exists?(list_id: li['inventory_site_ref']['list_id'])
                                li_data[:site_id] = Site.find_by(list_id: li['inventory_site_ref']['list_id']).id
                            end
                        end
                       
                        # Now we need to record these line items
                        if LineItem.exists?(txn_id: li['txn_line_id'])
                            lineitemupdate = LineItem.find_by(txn_id: li['txn_line_id'])
                            # Has this LineItem actually been modified?

                            if invoiceupdate.c_edit != qb_inv['edit_sequence']
                                lineitemupdate.update(li_data)
                            end
                        else
                            LineItem.create(li_data)
                        end
                    end

                # we need this if the line item only has one entry.   
                elsif !qb_inv['credit_memo_line_ret'].blank? 
                    li_data = {}
                    li = qb_inv['credit_memo_line_ret']
                    # We need to match the lineitem with order id
                    # We just recorded it and could pull it via find.
                    li_data[:credit_memo_id] = CreditMemo.find_by(txn_id: qb_inv['txn_id']).id

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

                    if qb_inv['exchange_rate'] != 1.0 and !li['amount'].nil?
                        li_data[:homecurrency_amount] = (li_data[:amount] * qb_inv['exchange_rate'].to_f)
                    else
                        li_data[:homecurrency_amount] = li_data[:amount]
                    end
                    
                    if li['inventory_site_ref']
                        if Site.exists?(list_id: li['inventory_site_ref']['list_id'])
                            li_data[:site_id] = Site.find_by(list_id: li['inventory_site_ref']['list_id']).id
                        end
                    end
                   
                    # Now we need to record these line items
                    if LineItem.exists?(txn_id: li['txn_line_id'])
                        lineitemupdate = LineItem.find_by(txn_id: li['txn_line_id'])
                        # Has this LineItem actually been modified?

                        if invoiceupdate.c_edit != qb_inv['edit_sequence']
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
        elsif !r['credit_memo_ret'].blank? 
            qb_inv = r['credit_memo_ret']
            invoice_data = {}
                invoice_data[:txn_id] = qb_inv['txn_id']
                invoice_data[:c_invoicenumber] = qb_inv['ref_number']
                invoice_data[:c_edit] = qb_inv['edit_sequence']
                invoice_data[:c_date] = qb_inv['txn_date']
                invoice_data[:c_balance_due] = qb_inv['balance_remaining_in_home_currency']
                invoice_data[:c_qbcreate] = qb_inv['time_created']
                invoice_data[:c_qbupdate] = qb_inv['time_modified']
                invoice_data[:c_template] = qb_inv['template_ref']['full_name']

            if qb_inv['currency_ref']
                currency_ref = qb_inv['currency_ref']['full_name']
                invoice_data[:currency_ref] = qb_inv['currency_ref']['full_name']
                invoice_data[:exchange_rate] = qb_inv['exchange_rate']
                if currency_ref == "Canadian Dollar"
                    invoice_data[:c_subtotal] = (qb_inv['subtotal'] * invoice_data[:exchange_rate])
                else
                    invoice_data[:c_subtotal] = qb_inv['subtotal']
                end
            end

            if qb_inv['po_number']
                invoice_data[:c_po] = qb_inv['po_number']
            end

            if qb_inv['class_ref']
                invoice_data[:c_class] = qb_inv['class_ref']['full_name']
            end

            if qb_inv['ship_date']
                invoice_data[:c_ship] = qb_inv['ship_date']
            end

            if qb_inv['due_date']
                invoice_data[:c_duedate] = qb_inv['due_date']
            end

            if qb_inv ['ship_method_ref']
                invoice_data[:c_via] = qb_inv['ship_method_ref']['full_name']
            end

            
            if qb_inv['customer_ref']
                invoice_data[:customer_id] = Customer.find_by(list_id: qb_inv['customer_ref']['list_id']).id
                invoice_data[:c_name] = qb_inv['customer_ref']['full_name']
            end

            # <>2 Need to figure out a way to execute on lineitems
          
            if qb_inv['ship_address']
                invoice_data[:c_ship1] = qb_inv['ship_address']['addr1']
                invoice_data[:c_ship2] = qb_inv['ship_address']['addr2']
                invoice_data[:c_ship3] = qb_inv['ship_address']['addr3']
                invoice_data[:c_ship4] = qb_inv['ship_address']['addr4']
                invoice_data[:c_ship5] = qb_inv['ship_address']['addr5']
                invoice_data[:c_shipcity] = qb_inv['ship_address']['city']
                invoice_data[:c_shipstate] = qb_inv['ship_address']['state']
                invoice_data[:c_shippostal] = qb_inv['ship_address']['postal_code']
                invoice_data[:c_shipcountry] = qb_inv['ship_address']['country']
            end
            
            if qb_inv['sales_rep_ref']
                invoice_data[:c_rep] = qb_inv['sales_rep_ref']['full_name']
            end

            # We need to create the invoice first, so we can get it's ID.
            if CreditMemo.exists?(txn_id: invoice_data[:txn_id])
                invoiceupdate = CreditMemo.find_by(txn_id: invoice_data[:txn_id])
                    # before updating, lets find out if it's neccessary by filtering by modified
                    if invoiceupdate.c_edit != qb_inv['edit_sequence']
                        invoiceupdate.update(invoice_data)
                    end
            else
                CreditMemo.create(invoice_data)
            end

# ----------------> Start Line Item
            # Line items are recorded if they are an array
            if qb_inv['credit_memo_line_ret'].is_a? Array
                
                
                qb_inv['credit_memo_line_ret'].each do |li|
                
                    li_data = {}

                    # We need to match the lineitem with order id
                    # We just recorded it and could pull it via find.
                    li_data[:credit_memo_id] = CreditMemo.find_by(txn_id: qb_inv['txn_id']).id

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

                    if qb_inv['exchange_rate'] != 1.0 and !li['amount'].nil?
                        li_data[:homecurrency_amount] = (li_data[:amount] * qb_inv['exchange_rate'].to_f)
                    else
                        li_data[:homecurrency_amount] = li_data[:amount]
                    end
                
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

                        if invoiceupdate.c_edit != qb_inv['edit_sequence']
                            lineitemupdate.update(li_data)
                        end
                    else
                        LineItem.create(li_data)
                    end
                end

            # we need this if the line item only has one entry.   
            elsif !qb_inv['credit_memo_line_ret'].blank? 
                li_data = {}
                li = qb_inv['credit_memo_line_ret']
                # We need to match the lineitem with order id
                # We just recorded it and could pull it via find.
                li_data[:credit_memo_id] = CreditMemo.find_by(txn_id: qb_inv['txn_id']).id

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

                if qb_inv['exchange_rate'] != 1.0 and !li['amount'].nil?
                    li_data[:homecurrency_amount] = (li_data[:amount] * qb_inv['exchange_rate'].to_f)
                else
                    li_data[:homecurrency_amount] = li_data[:amount]
                end
                
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

                    if invoiceupdate.c_edit != qb_inv['edit_sequence']
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
    Log.create(worker_name: "CreditMemoLoader")

    end
end