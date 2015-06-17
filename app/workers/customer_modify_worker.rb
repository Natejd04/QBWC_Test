require 'qbwc'

class CustomerModifyWorker < QBWC::Worker
    
#    This worker was setup for testing purposes, it does work, but not reccomened to use during production.
#    ** make decision if you want to use this in production
    def requests(job)
         Rails.logger.info("Starting customer modify")
        
#        if the customer was updated after being created, then push update to QB
#        currently only setup to update address
        customers = Customer.where("updated_at > created_at")
            updated_customers = []   
                customers.each do |customer|
                        updated_customers << {
                            :customer_mod_rq => {
                                :customer_mod => {
                                    :list_id => customer.listid,
                                    :edit_sequence => customer.edit_sq,
                                    :bill_address => { :addr1 => customer.address, :Addr2 => customer.address2, :City => customer.city, :State => customer.state, :PostalCode => customer.zip}
                                    }
                                }
                            }
                end
            return updated_customers
                    
    end

    def handle_response(r, session, job, request, data)
        # handle_response will get customers in groups of 100. When this is 0, we're done.
        # we could receive a completed response, but lets just log that its completed.
        Rails.logger.info("This is the end of the customer mod")
        
      
    end

    
end
