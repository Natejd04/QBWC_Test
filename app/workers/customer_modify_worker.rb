require 'qbwc'

class CustomerModifyWorker < QBWC::Worker

    def requests(job)
         Rails.logger.info("This is the start --------- START")
         customers = Customer.all.order "id ASC"
            customers.each do |customer|
                    if customer.updated_at > customer.created_at
                        
            {
                    :customer_mod_rq => {
                        :customer_mod => {
                            :list_id => customer.listid,
                            :edit_sequence => customer.edit_sq,
                            :bill_address => { :addr1 => customer.address, :Addr2 => customer.address2, :City => customer.city, :State => customer.state, :PostalCode => customer.zip}
                            }
                        }
            }
                    else
                        Rails.logger.info("No update required on *" + customer.name + "*")
                    end
                end
    end

    def handle_response(r, session, job, request, data)
        # handle_response will get customers in groups of 100. When this is 0, we're done.
        Rails.logger.info("This is the end of the customer mod")
        
      
    end

    
end
