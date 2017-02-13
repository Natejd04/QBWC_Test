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

        # We need to confirm that our results are an array           
        
        if r['invoice_ret'].is_a? Array

            r['invoice_ret'].each do |qb_item|
                item_data = {}
                item_data[:txn_id] = qb_item['ref_number']
                item_data[:time_created] = qb_item['time_created']
                item_data[:txn_date] = qb_item['txn_date']
                item_data[:name] = qb_item['customer_ref']['full_name']
                item_data[:template_ref] = qb_item['template_ref']['full_name']
                
                if qb_item['memo']
                    item_data[:memo] = qb_item['memo']
                end
                if qb_item['fob']
                    item_data[:packages] = qb_item['fob']
                end
                item_data[:emailed] = false

                # This is the block for the ship to info
                if qb_item['ship_address']
                    item_data[:ship1] = qb_item['ship_address']['addr1']
                    item_data[:ship2] = qb_item['ship_address']['addr2']
                    item_data[:ship3] = qb_item['ship_address']['addr3']
                    item_data[:ship4] = qb_item['ship_address']['addr4']
                    item_data[:ship5] = qb_item['ship_address']['addr5']
                    item_data[:shipcity] = qb_item['ship_address']['city']
                    item_data[:shipstate] = qb_item['ship_address']['state']
                    item_data[:shippostal] = qb_item['ship_address']['postal_code']
                    item_data[:shipcountry] = qb_item['ship_address']['country']
                end

                    if qb_item['po_number']                    
                        email = qb_item['po_number']
                        if email =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
                            item_data[:email] = email     
                        end
                    end
                    if item_data[:email].nil?    
                        customer = Customer.find_by listid: qb_item['customer_ref']['list_id']
                        item_data[:email] = customer.email
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
                    
                Tracking.create(item_data)
            end

         # Now we will check to make sure the object isn't empty.   
        elsif !r['invoice_ret'].blank? 
            item_data = {}
                item_data[:txn_id] = r['invoice_ret']['ref_number']
                item_data[:time_created] = r['invoice_ret']['time_created']
                item_data[:txn_date] = r['invoice_ret']['txn_date']
                item_data[:name] = r['invoice_ret']['customer_ref']['full_name']
                item_data[:template_ref] = r['invoice_ret']['template_ref']['full_name']
                
                if r['invoice_ret']['memo']
                    item_data[:memo] = r['invoice_ret']['memo']
                end
                if r['invoice_ret']['fob']
                    item_data[:packages] = r['invoice_ret']['fob']
                end
                item_data[:emailed] = false

                # This is the block for the ship to info
                if r['invoice_ret']['ship_address']
                    item_data[:ship1] = r['invoice_ret']['ship_address']['addr1']
                    item_data[:ship2] = r['invoice_ret']['ship_address']['addr2']
                    item_data[:ship3] = r['invoice_ret']['ship_address']['addr3']
                    item_data[:ship4] = r['invoice_ret']['ship_address']['addr4']
                    item_data[:ship5] = r['invoice_ret']['ship_address']['addr5']
                    item_data[:shipcity] = r['invoice_ret']['ship_address']['city']
                    item_data[:shipstate] = r['invoice_ret']['ship_address']['state']
                    item_data[:shippostal] = r['invoice_ret']['ship_address']['postal_code']
                    item_data[:shipcountry] = r['invoice_ret']['ship_address']['country']
                end

                    if r['invoice_ret']['po_number']                    
                        email = r['invoice_ret']['po_number']
                            if email =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
                                item_data[:email] = email     
                            end
                    end    
                    if item_data[:email].nil?
                        customer = Customer.find_by listid: r['invoice_ret']['customer_ref']['list_id']
                        item_data[:email] = customer.email
                    end
                
                item_data[:tracking] = r['invoice_ret']['other']
                    
                    if r['invoice_ret']['other']
                        tracking = r['invoice_ret']['other']
                            if tracking =~ /^1Z/
                                item_data[:ship_method] = "UPS"
                            elsif tracking =~ /\d{20,22}/
                                    item_data[:ship_method] = "USPS"
                            else
                                item_data[:ship_method] = "FedEx"
                            end
                    end
            Tracking.create(item_data)
        end

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
            


 # Template Ref ID 8000001A-1357145643
