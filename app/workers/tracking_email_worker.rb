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
                :txn_date_range_filter => {"from_txn_date" => Date.today, "to_txn_date" => Date.today},
                :include_line_items => true
            }
        }
    end

    def handle_response(r, session, job, request, data)
        # we could receive a completed response, but lets just log that its completed.
        # Rails.logger.info("This is the end of the customer mod")
        complete = r['xml_attributes']['iteratorRemainingCount'] == '0'

        # if no invoices from current day, we skip this.
      if r['invoice_ret']


        r['invoice_ret'].each do |qb_item|
            item_data = {}
            item_data[:txn_id] = qb_item['txn_number']
            item_data[:time_created] = qb_item['txn_created']
            item_data[:txn_date] = qb_item['txn_date']
            item_data[:name] = qb_item['customer_ref']['full_name']
            item_data[:template_ref] = qb_item['template_ref']['full_name']
                if qb_item['po_number']                    
                    email = qb_item['po_number']
                        if email =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
                            item_data[:email] = email                           
                        end
                end
            
            item_data[:tracking] = qb_item['other']
                
                if qb_item['other']
                    tracking = qb_item['other']
                        if tracking =~ /^1Z/
                            item_data[:ship_method] = "UPS"
                        elsif tracking =~ /\d{20,22}/
                                item_data[:ship_method] = "USPS"
                        else
                            item_data[:ship_method] = "FedEx"
                        end
                end

       
         # binding.pry


            # if qb_item['invoice_line_ret']
            #    qb_item['invoice_line_ret'].each_with_index do |list_item, index|            
            #             if qb_item['invoice_line_ret'][0]['desc']                             
            #                     email = qb_item['invoice_line_ret'][0]['desc']
            #                     if email =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
            #                         item_data[:email] = qb_item['invoice_line_ret'][0]['desc']
            #                         item_data[:tracking] = qb_item['invoice_line_ret'][1]['desc']
            #                     end
            #                        email_1 = qb_item['invoice_line_ret'][1]['desc']
            #                     if email_1 =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
            #                         item_data[:email] = qb_item['invoice_line_ret'][1]['desc']
            #                         item_data[:tracking] = qb_item['invoice_line_ret'][0]['desc']
            #                     end
            #             end
            #             # i = i + 1
            #     end
            # end
            # binding.pry
            Tracking.create(item_data)  
        end
    else
        Rails.logger.info("Invoice hasn't been changed")
    end  
end

    
end
 # Template Ref ID 8000001A-1357145643
