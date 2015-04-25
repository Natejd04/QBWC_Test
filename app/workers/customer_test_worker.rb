require 'qbwc'

class CustomerTestWorker < QBWC::Worker

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

        r['customer_ret'].each do |qb_cus|
            qb_id = qb_cus['list_id']
            qb_name = qb_cus['name']
            qb_address1 = qb_cus['bill_address']['addr1']
            qb_address2 = qb_cus['bill_address']['addr2']
            qb_city = qb_cus['bill_address']['city']
            qb_state = qb_cus['bill_address']['state']
            qb_postal = qb_cus['bill_address']['postal_code']
            customer = Customer.find_by name: qb_name
            if customer
                customer.update(address: qb_address1, address2: qb_address2, city: qb_city, state: qb_state, zip: qb_postal)
            else
                Customer.create(name: qb_name, address: qb_address1, address2: qb_address2, city: qb_city, state: qb_state, zip: qb_postal)
            end
#            Rails.logger.info "Here is a test line"
        end
    end

end