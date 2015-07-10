require 'qbwc'

class CustomerTestWorker < QBWC::Worker

#    This worker is used to grab customer info and create records in rails server.
#    currently only grabbing 50 results at a time
    def requests(job)
        {
            :customer_query_rq => {
                :xml_attributes => { "requestID" =>"1", 'iterator'  => "Start" },
                :max_returned => 100
            }
        }
    end

    def handle_response(r, session, job, request, data)
        # handle_response will get customers in groups of 100. When this is 0, we're done.
        complete = r['xml_attributes']['iteratorRemainingCount'] == '0'

#        We will then loop through each customer and create records.
        r['customer_ret'].each do |qb_cus|
            customer_data = {}
            customer_data[:listid] = qb_cus['list_id']
            customer_data[:name] = qb_cus['name']
            customer_data[:edit_sq] = qb_cus['edit_sequence']
            if qb_cus['bill_address']
                customer_data[:address] = qb_cus['bill_address']['addr1']
                customer_data[:address2] = qb_cus['bill_address']['addr2']
                customer_data[:city] = qb_cus['bill_address']['city']
                customer_data[:state] = qb_cus['bill_address']['state']
                customer_data[:zip] = qb_cus['bill_address']['postal_code']
            end
            if qb_cus['ship_address']
                customer_data[:ship_address] = qb_cus['ship_address']['addr1']
                customer_data[:ship_address2] = qb_cus['ship_address']['addr2']
                customer_data[:ship_address3] = qb_cus['ship_address']['addr3']
                customer_data[:ship_address4] = qb_cus['ship_address']['addr4']
                customer_data[:ship_address5] = qb_cus['ship_address']['addr5']
                customer_data[:ship_city] = qb_cus['ship_address']['city']
                customer_data[:ship_state] = qb_cus['ship_address']['state']
                customer_data[:ship_zip] = qb_cus['ship_address']['postal_code']
            end
            customer = Customer.find_by listid: customer_data[:listid]
            
#            if customer doesn't exist create record.
            if customer.blank?
                Customer.create(customer_data)
            
#           was the customer updated after created, if so we need a new edit_sq
#            <> ideally if we can get updated in QB, then we could check updated in QB vs. Update in database and preform accurately.
#            elsif customer.updated_at > customer.created_at
#                customer.update(edit_sq: customer_data[:edit_sq])
#            
#            if the customer update and created are the same, let's update edit sequence anyways. 
            else 
                customer.update(customer_data)
                Rails.logger.info("Customer info is the same")
            end
        end
    
      
 end

    
end