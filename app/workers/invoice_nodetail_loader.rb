require 'qbwc'

class InvoiceWorker < QBWC::Worker

    # This worker is going to be used to test. It will pre-load, with 2017 invoices.
    # The goal is to enable this worker to update all invoices once loaded.
    # Currently set for no line-item import, that will be phase 2.
    
    def requests(job)
        {
            :invoice_query_rq => {
                :xml_attributes => { "requestID" =>"1"},
                :modified_date_range_filter => {"from_modified_date" => "2017-01-01", "to_modified_date" => "2017-12-31"},
                :include_line_items => false
            }
        }
    end
    # old code, that i don't think is supported anymore
    # :from_modified_date => Customer.order("updated_at").last[:updated_at].strftime("%Y-%m-%d"),
    #             :to_modified_date => DateTime.now.strftime("%Y-%m-%d")

    def handle_response(r, session, job, request, data)
        # handle_response will get customers in groups of 100. When this is 0, we're done.
        complete = r['xml_attributes']['iteratorRemainingCount'] == '0'

        if r['invoice_ret']

#        We will then loop through each invoice and create records.
            r['invoice_ret'].each do |qb_inv|
                invoice_data = {}
                invoice_data[:txn_id] = qb_inv['txn_id']
                invoice_data[:invoice_number] = qb_inv['txn_number']
                invoice_data[:c_edit] = qb_inv['edit_sequence']
                invoice_data[:c_date] = qb_inv['txn_date']

                if qb_inv['po_number']
                    invoice_data[:c_po] = qb_inv['po_number']
                end

                # <>2 We will use this eventually
                # if qb_inv['customer_ref']
                #     invoice_data[:customer_id] = Customer.find_by(listid: qb_inv['customer_ref']['list_id']).id
                #     invoice_data[:c_name] = qb_inv['customer_ref']['full_name']
                # end
              
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
                
            end
        end
    end
end