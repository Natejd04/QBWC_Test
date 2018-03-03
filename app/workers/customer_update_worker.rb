require 'qbwc'

class CustomerUpdateWorker < QBWC::Worker

    # Pre-load all customer data, only if no data exists in the Log table.
    # If data exists in the Log table, we take the last pull date as a sort filter
    # We will limit this to 1, the most recent entry
    if Log.exists?(worker_name: 'CustomerUpdateWorker')

        LastUpdate = Log.where(worker_name: 'CustomerUpdateWorker').order(created_at: :desc).limit(1)
        LastUpdate = LastUpdate[0][:created_at].strftime("%Y-%m-%d")
    else
        # This is preloading data based on no records in the log table
        LastUpdate = "2014-01-01"
    
    end

    # Modified this worker, you can use this to load all data, and have it continually run.
    def requests(job)
        {
            :customer_query_rq => {
                :xml_attributes => { "requestID" =>"1", 'iterator'  => "Start" },
                :max_returned => 1000,
                :from_modified_date => LastUpdate,
                :to_modified_date => Date.today + (1.0)          
            }
        }
    end
    

    def handle_response(r, session, job, request, data)
        # handle_response will get customers in groups of 100. When this is 0, we're done.
        complete = r['xml_attributes']['iteratorRemainingCount'] == '0'

        # if no customer updates occured we skip this.
        # if r['customer_ret']
        if r['customer_ret'].is_a? Array
    #        We will then loop through each customer and create records.
            r['customer_ret'].each do |qb_cus|
                customer_data = {}
                customer_data[:listid] = qb_cus['list_id']
                customer_data[:name] = qb_cus['name']
                customer_data[:edit_sq] = qb_cus['edit_sequence']
                customer_data[:email] = qb_cus['email']
                customer_data[:qbcreate] = qb_cus['time_created']
                customer_data[:qbupdate] = qb_cus['time_modified']
               
                if qb_cus['customer_type_ref']
                    customer_data[:customer_type_id] = qb_cus['customer_type_ref']['list_id']
                    customer_data[:customer_type] = qb_cus['customer_type_ref']['full_name']
                end
                
                if qb_cus['sales_rep_ref']
                    customer_data[:rep] = qb_cus['sales_rep_ref']['full_name']
                end
               
                if qb_cus['bill_address']
                    customer_data[:address] = qb_cus['bill_address']['addr1']
                    customer_data[:address2] = qb_cus['bill_address']['addr2']
                    customer_data[:city] = qb_cus['bill_address']['city']
                    customer_data[:state] = qb_cus['bill_address']['state']
                    customer_data[:zip] = qb_cus['bill_address']['postal_code']
                end
               
                if qb_cus['ship_address']
                    customer_data[:ship_address] = qb_cus['ship_address']['addr1']
                    customer_data[:ship_address2] = qb_cus['ship_address']['addr2']
                    customer_data[:ship_address3] = qb_cus['ship_address']['addr3']
                    customer_data[:ship_address4] = qb_cus['ship_address']['addr4']
                    customer_data[:ship_address5] = qb_cus['ship_address']['addr5']
                    customer_data[:ship_city] = qb_cus['ship_address']['city']
                    customer_data[:ship_state] = qb_cus['ship_address']['state']
                    customer_data[:ship_zip] = qb_cus['ship_address']['postal_code']
                end
                

                if Customer.exists?(listid: qb_cus['list_id'])
                customerid = Customer.find_by(listid: customer_data[:listid])
                    
                    # We want to confirm that it's neccessary to update this record first.
                    if customerid.edit_sq != qb_cus['edit_sequence']
                        customerid.update(customer_data)
                    end
                
                else
                   
                    # the customer didn't exists so we will create
                    Customer.create(customer_data)
                
                end
            end
            # let's record that this worker was ran, so that it's timestamped in logs
            # Moved the log creating to be within the handle response incase the response errors, I don't want a log.
            Log.create(worker_name: "CustomerUpdateWorker")

                # Now we will check to make sure the object isn't empty.   
        elsif !r['customer_ret'].blank? 
            customer_data = {}
            customer_data[:listid] = r['customer_ret']['list_id']
            customer_data[:name] = r['customer_ret']['name']
            customer_data[:edit_sq] = r['customer_ret']['edit_sequence']
            customer_data[:email] = r['customer_ret']['email']
            customer_data[:qbcreate] = r['customer_ret']['time_created']
            customer_data[:qbupdate] = r['customer_ret']['time_modified']
             
            if r['customer_ret']['customer_type_ref']
                customer_data[:customer_type_id] = r['customer_ret']['customer_type_ref']['list_id']
                customer_data[:customer_type] = r['customer_ret']['customer_type_ref']['full_name']
            end
              
            if r['customer_ret']['sales_rep_ref']
                customer_data[:rep] = r['customer_ret']['sales_rep_ref']['full_name']
            end
            
            if r['customer_ret']['bill_address']
                customer_data[:address] = r['customer_ret']['bill_address']['addr1']
                customer_data[:address2] = r['customer_ret']['bill_address']['addr2']
                customer_data[:city] = r['customer_ret']['bill_address']['city']
                customer_data[:state] = r['customer_ret']['bill_address']['state']
                customer_data[:zip] = r['customer_ret']['bill_address']['postal_code']
            end
                
            if r['customer_ret']['ship_address']
                customer_data[:ship_address] = r['customer_ret']['ship_address']['addr1']
                customer_data[:ship_address2] = r['customer_ret']['ship_address']['addr2']
                customer_data[:ship_address3] = r['customer_ret']['ship_address']['addr3']
                customer_data[:ship_address4] = r['customer_ret']['ship_address']['addr4']
                customer_data[:ship_address5] = r['customer_ret']['ship_address']['addr5']
                customer_data[:ship_city] = r['customer_ret']['ship_address']['city']
                customer_data[:ship_state] = r['customer_ret']['ship_address']['state']
                customer_data[:ship_zip] = r['customer_ret']['ship_address']['postal_code']
            end
            
            # We are checking to see if this customer already exists
            if Customer.exists?(listid: r['customer_ret']['list_id'])
                customerid = Customer.find_by(listid: customer_data[:listid])
                    
                # we know they exists, but is it neccessary to update this record.
                if customerid.edit_sq != r['customer_ret']['edit_sequence']
                    customerid.update(customer_data)
                end
                
            else
                # the customer didn't exists so we will create
                Customer.create(customer_data) 
            end
            # let's record that this worker was ran, so that it's timestamped in logs
            # Moved the log create to be within the handle response incase the response has errors and I don't want it to log.
            Log.create(worker_name: "CustomerUpdateWorker")
        end
    end
end