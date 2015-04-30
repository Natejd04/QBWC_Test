require 'qbwc'

class CustomerModifyWorker < QBWC::Worker

    def requests(job)
         Rails.logger.info("This is the start --------- START")
#         Rails.logger.info("the start of customers ------------ Customers " + customer.name + " " + customer.address)
#        customers = Customer.where("updated_at > created_at")
#            customers.each do |customer|
        {
                    :customer_mod_rq => {
                        :customer_mod => {
                            :list_id => "3D0000-1040150817",
                            :edit_sequence => "1576431701",
                            :bill_address => { :addr1 => "1234", :Addr2 => "010", :City => "Snoho", :State => "WA", :PostalCode => "98104"}
                            }
                        }
                }
                
    end

    def handle_response(r, session, job, request, data)
        # handle_response will get customers in groups of 100. When this is 0, we're done.
        Rails.logger.info("This is the end of the customer mod")
        
      
    end

    
end
