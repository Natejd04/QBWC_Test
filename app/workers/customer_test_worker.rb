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
            customer_data = {}
           customer_data[:listid] = qb_cus['list_id']
            customer_data[:name] = qb_cus['name']
            if qb_cus['bill_address']
                customer_data[:address] = qb_cus['bill_address']['addr1']
                customer_data[:address2] = qb_cus['bill_address']['addr2']
                customer_data[:city] = qb_cus['bill_address']['city']
                customer_data[:state] = qb_cus['bill_address']['state']
                customer_data[:zip] = qb_cus['bill_address']['postal_code']
            end
            customer = Customer.find_by name: customer_data[:name]
            if customer
                customer.update(customer_data)
            else
                Customer.create(customer_data)
            end
#            Rails.logger.info "Here is a test line"
        end
    end

end