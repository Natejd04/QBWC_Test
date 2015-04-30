require 'qbwc'

class CustomerModifyWorker < QBWC::Worker

    def requests(job)
         Rails.logger.info("This is the start --------- START")
         @customers = Customer.where("updated_at > created_at")
            @customers.each do |customer|
                Rails.logger.info("the start of customers ------------ Customers " + customer.name + " " + customer.address)
            {
                    :customer_mod_rq => {
                        :customer_mod => {
                            :list_id => customer.listid,
                            :edit_sequence => customer.edit_sq,
                            :bill_address => { :addr1 => customer.address, :Addr2 => customer.address2, :City => customer.city, :State => customer.state, :PostalCode => customer.zip}
                            }
                        }
            }
                end
    end

    def handle_response(r, session, job, request, data)
        # handle_response will get customers in groups of 100. When this is 0, we're done.
        Rails.logger.info("This is the end of the customer mod")
        
      
    end

    
end
