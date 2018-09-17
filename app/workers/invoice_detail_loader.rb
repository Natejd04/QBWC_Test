require 'qbwc'
require 'concerns/qbwc_helper'

class InvoiceDetailLoader < QBWC::Worker
    extend QbwcHelper
    
    #We will establish which worker this is. This will be used through-out.
    WorkerName = "InvoiceDetailLoader"
    
    def requests(job)
        {
            :invoice_query_rq => {
                # :max_returned => 100,
                :modified_date_range_filter => {"from_modified_date" => qbwc_log_init(WorkerName), "to_modified_date" => Date.today + (1.0)},
                :include_line_items => true,
                :include_linked_txns => true
            }
        }
    end

    def handle_response(r, session, job, request, data)
        # handle_response will get customers in groups of 100. When this is 0, we're done.
        # complete = r['xml_attributes']['iteratorRemainingCount'] == '0'
        if r['account_ret'].nil? 
            # This will log if the data returned was empty and no updates occured, but it did run.
            qbwc_log_create(WorkerName, 0, "none", nil)            
        else

            # We will then loop through each invoice and create records.
            if r['invoice_ret'].is_a? Array 
                i = 0
                r['invoice_ret'].each do |qb_inv|
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

                    if qb_inv['memo']
                        invoice_data[:memo] = qb_inv['memo']
                    end
                    
                    if qb_inv['fob']
                        invoice_data[:fob] = qb_inv['fob']
                    end

                    if qb_inv['po_number']                    
                        email = qb_inv['po_number']
                        if email =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
                            invoice_data[:email] = email     
                        end
                    end
                    
                    invoice_data[:to_email] = false

                    if invoice_data[:email].nil?
                        invoice_data[:email] = Customer.find(invoice_data[:customer_id]).email
                    end

                    if qb_inv['other']
                        invoice_data[:tracking] = qb_inv['other']
                            if invoice_data[:tracking] =~ /^1Z/
                                invoice_data[:ship_method] = "UPS"
                            elsif invoice_data[:tracking] =~ /\d{20,22}/
                                    invoice_data[:ship_method] = "USPS"
                            elsif invoice_data[:tracking] =~ /(\b96\d{20}\b)|(\b\d{15}\b)|(\b\d{12}\b)/
                                invoice_data[:ship_method] = "FedEx"
                            else
                                invoice_data[:ship_method] = "LTL or Pickup"
                            end
                    end
                    
                    if qb_inv['template_ref']['full_name'] == "* Zing Whls/Consumer Invoice V2"
                        invoice_data[:emailable] = true
                    end

                    # Apparently QB SDK has no way to pull sales order link, without this line
                   if qb_inv['linked_txn'].is_a? Array
                        qb_inv['linked_txn'].each do |link|
                            if link['txn_type'] == "SalesOrder"
                                invoice_data[:sales_order_txn] = link['txn_id']
                                invoice_data[:sales_order_ref] = link['ref_number']
                                orderupdate = Order.find_by(txn_id: invoice_data[:sales_order_txn])
                                if orderupdate.nil?
                                else
                                   orderupdate.update(c_invoiced: "qbwc_closed")
                                end
                            end
                        end
                    elsif !qb_inv['linked_txn'].blank?
                        if qb_inv['linked_txn'].nil?
                        else
                            if qb_inv['linked_txn']['txn_type'] == "SalesOrder"
                                invoice_data[:sales_order_txn] = qb_inv['linked_txn']['txn_id']
                                invoice_data[:sales_order_ref] = qb_inv['linked_txn']['ref_number']
                                orderupdate = Order.find_by(txn_id: invoice_data[:sales_order_txn])
                                if orderupdate.nil?
                                else
                                    orderupdate.update(c_invoiced: "qbwc_closed")
                                end
                            end
                        end
                    end

                    # We need to create the invoice first, so we can get it's ID.
                    if Invoice.exists?(txn_id: invoice_data[:txn_id])
                        invoiceupdate = Invoice.find_by(txn_id: invoice_data[:txn_id])
                            # before updating, lets find out if it's neccessary by filtering by modified
                            if invoiceupdate.c_edit != qb_inv['edit_sequence']
                                invoiceupdate.update(invoice_data)
                            end
                    else
                        Invoice.create(invoice_data)
                    end

    # ----------------> Start Line Item
                    # Line items are recorded if they are an array
                    if qb_inv['invoice_line_ret'].is_a? Array
                        
                        
                        qb_inv['invoice_line_ret'].each do |li|
                        
                            li_data = {}

                            # We need to match the lineitem with order id
                            # We just recorded it and could pull it via find                        
                            invoice_id = li_data[:order_id] = Invoice.find_by(txn_id: qb_inv['txn_id'])
                            li_data[:invoice_id] = invoice_id.id

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
                    elsif !qb_inv['invoice_line_ret'].blank? 
                        li_data = {}
                        li = qb_inv['invoice_line_ret']
                        # We need to match the lineitem with order id
                        # We just recorded it and could pull it via find.
                        invoice_id = li_data[:order_id] = Invoice.find_by(txn_id: qb_inv['txn_id'])
                        li_data[:invoice_id] = invoice_id.id

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
                    i += 1
        # ---------------> End Line Item     
                
                # This is the end of the original invoice each do
                end
                qbwc_log_create(WorkerName, 0, "updates", i)
      
            # If the obect wasn't an array and only one record was present we will record that
            # No loop or each process
            elsif !r['invoice_ret'].blank? 
                qb_inv = r['invoice_ret']
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

                if qb_inv['memo']
                    invoice_data[:memo] = qb_inv['memo']
                end
                
                if qb_inv['fob']
                    invoice_data[:fob] = qb_inv['fob']
                end

                if qb_inv['po_number']                    
                    email = qb_inv['po_number']
                    if email =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
                        invoice_data[:email] = email     
                    end
                end

                invoice_data[:to_email] = false

                if invoice_data[:email].nil?
                    invoice_data[:email] = Customer.find(invoice_data[:customer_id]).email
                end

                if qb_inv['other']
                    invoice_data[:tracking] = qb_inv['other']
                        if invoice_data[:tracking] =~ /^1Z/
                            invoice_data[:ship_method] = "UPS"
                        elsif invoice_data[:tracking] =~ /\d{20,22}/
                                invoice_data[:ship_method] = "USPS"
                        elsif invoice_data[:tracking] =~ /(\b96\d{20}\b)|(\b\d{15}\b)|(\b\d{12}\b)/
                            invoice_data[:ship_method] = "FedEx"
                        else
                            invoice_data[:ship_method] = "LTL or Pickup"
                        end
                end
                
                if qb_inv['template_ref']['full_name'] == "* Zing Whls/Consumer Invoice V2"
                    invoice_data[:emailable] = true
                end

                    # Apparently QB SDK has no way to pull sales order link, without this line
                if qb_inv['linked_txn'].is_a? Array
                    qb_inv['linked_txn'].each do |link|
                        if link['txn_type'] == "SalesOrder"
                            invoice_data[:sales_order_txn] = link['txn_id']
                            invoice_data[:sales_order_ref] = link['ref_number']
                            orderupdate = Order.find_by(txn_id: invoice_data[:sales_order_txn])
                            if orderupdate.nil?
                            else
                               orderupdate.update(c_invoiced: "qbwc_closed")
                            end
                        end
                    end
                elsif !qb_inv['linked_txn'].blank?
                    if qb_inv['linked_txn'].nil?
                    else
                        if qb_inv['linked_txn']['txn_type'] == "SalesOrder"
                            invoice_data[:sales_order_txn] = qb_inv['linked_txn']['txn_id']
                            invoice_data[:sales_order_ref] = qb_inv['linked_txn']['ref_number']
                            orderupdate = Order.find_by(txn_id: invoice_data[:sales_order_txn])
                            if orderupdate.nil?
                            else
                                orderupdate.update(c_invoiced: "qbwc_closed")
                            end
                        end
                    end
                end


                # We need to create the invoice first, so we can get it's ID.
                if Invoice.exists?(txn_id: invoice_data[:txn_id])
                    invoiceupdate = Invoice.find_by(txn_id: invoice_data[:txn_id])
                        # before updating, lets find out if it's neccessary by filtering by modified
                        if invoiceupdate.c_edit != qb_inv['edit_sequence']
                            invoiceupdate.update(invoice_data)
                        end
                else
                    Invoice.create(invoice_data)
                end

    # ----------------> Start Line Item
                # Line items are recorded if they are an array
                if qb_inv['invoice_line_ret'].is_a? Array
                    
                    
                    qb_inv['invoice_line_ret'].each do |li|
                    
                        li_data = {}

                        # We need to match the lineitem with order id
                        # We just recorded it and could pull it via find.
                        invoice_id = li_data[:order_id] = Invoice.find_by(txn_id: qb_inv['txn_id'])
                        li_data[:invoice_id] = invoice_id.id

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
                elsif !qb_inv['invoice_line_ret'].blank? 
                    li_data = {}
                    li = qb_inv['invoice_line_ret']
                    # We need to match the lineitem with order id
                    # We just recorded it and could pull it via find.
                    invoice_id = li_data[:order_id] = Invoice.find_by(txn_id: qb_inv['txn_id'])
                    li_data[:invoice_id] = invoice_id.id

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
                qbwc_log_create(WorkerName, 0, "updates", "1")
            end
        qbwc_log_create(WorkerName, 0, "complete", nil)
        # This is the end of the empty statement
        end
    end
end
