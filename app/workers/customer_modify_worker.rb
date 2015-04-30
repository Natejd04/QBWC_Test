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
                            :list_id => "600000-1045612576",
                            :edit_sequence => "1544875287",
                            :bill_address => { :addr1 => "01 First Try", :Addr2 => "010", :City => "Snoho", :State => "WA", :PostalCode => "98104"}
                            }
                        }
            }
        {
                    :customer_mod_rq => {
                        :customer_mod => {
                            :list_id => "610000-1045612618",
                            :edit_sequence => "1544875287",
                            :bill_address => { :addr1 => "02 Second Try", :Addr2 => "010", :City => "Snoho", :State => "WA", :PostalCode => "98104"}
                            }
                        }
                }
                
    end

    def handle_response(r, session, job, request, data)
        # handle_response will get customers in groups of 100. When this is 0, we're done.
        Rails.logger.info("This is the end of the customer mod")
        
      
    end

    
end
