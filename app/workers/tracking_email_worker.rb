require 'qbwc'

class TrackingEmailWorker < QBWC::Worker
    
#    This worker was setup for testing purposes, it does work, but not reccomened to use during production.
#    ** make decision if you want to use this in production
    def requests(job)
         Rails.logger.info("Starting customer modify")
        
# def request all invoices (will filter results at the end)
        {
            :invoice_query_rq => {
                :xml_attributes => { "requestID" =>"1", 'iterator'  => "Start" },
                :max_returned => 10,
                :txn_date_range_filter => {"from_txn_date" => "2016-12-17", "to_txn_date" => "2016-12-18"},
                :include_line_items => true
            }
        }
    end

    def handle_response(r, session, job, request, data)
        # we could receive a completed response, but lets just log that its completed.
        # Rails.logger.info("This is the end of the customer mod")
        complete = r['xml_attributes']['iteratorRemainingCount'] == '0'

        # if no customer updates occured we skip this.
      if r['invoice_ret']

        r['invoice_ret'].each do |qb_item|
            item_data = {}
            item_data[:txn_id] = qb_item['txn_number']
            item_data[:time_created] = qb_item['time_created']
            item_data[:name] = qb_item['customer_ref']['full_name']
            item_data[:template_ref] = qb_item['template_ref']['full_name']        
       
         # binding.pry


            if qb_item['invoice_line_ret']
               qb_item['invoice_line_ret'].each_with_index do |list_item, index|            
                        if qb_item['invoice_line_ret'][0]['desc']                             
                                email = qb_item['invoice_line_ret'][0]['desc']
                                if email =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
                                    item_data[:email] = qb_item['invoice_line_ret'][0]['desc']
                                    item_data[:tracking] = qb_item['invoice_line_ret'][1]['desc']
                                end
                                   email_1 = qb_item['invoice_line_ret'][1]['desc']
                                if email_1 =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
                                    item_data[:email] = qb_item['invoice_line_ret'][1]['desc']
                                    item_data[:tracking] = qb_item['invoice_line_ret'][0]['desc']
                                end
                        end
                        # i = i + 1
                end
            end
            # binding.pry
            Tracking.create(item_data)  

        end
     
      end  
    end

    
end
 # Template Ref ID 8000001A-1357145643
