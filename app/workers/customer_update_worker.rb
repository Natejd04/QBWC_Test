require 'qbwc'

class CustomerUpdateWorker < QBWC::Worker

    # Pre-load all customer data, only if no data exists in the Log table.
    # If data exists in the Log table, we take the last pull date as a sort filter
    # We will limit this to 1, the most recent entry
    if Log.exists?(worker_name: 'CustomerUpdateWorker')

        LastUpdate = Log.where(worker_name: 'CustomerUpdateWorker').order(created_at: :desc).limit(1)
        LastUpdate = LastUpdate[0][:created_at].strftime("%Y-%m-%d")
        InitialLoad = false
    else
        # This is preloading data based on no records in the log table
        LastUpdate = "2014-01-01"
        InitialLoad = true
    
    end

    # Modified this worker, you can use this to load all data, and have it continually run.
    def requests(job)
        {
            :customer_query_rq => {
                :xml_attributes => { "requestID" =>"1", 'iterator'  => "Start" },
                :max_returned => 200, #required
                :from_modified_date => LastUpdate,
                :to_modified_date => Date.today + (1.0)          
            }
        }
    end
    

    def handle_response(r, session, job, request, data)
        # handle_response will get customers in groups of 100. When this is 0, we're done.
        complete = r['xml_attributes']['iteratorRemainingCount'] == '0'

        # if no customer updates occured we skip this.

        if r['customer_ret'].is_a? Array
    #        We will then loop through each customer and create records.
            r['customer_ret'].each do |qb_cus|
                customer_data = {}
                customer_data[:list_id] = qb_cus['list_id']
                customer_data[:name] = qb_cus['full_name']
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
                

                if Customer.exists?(list_id: qb_cus['list_id'])
                customerid = Customer.find_by(list_id: customer_data[:list_id])
                    
                    # We want to confirm that it's neccessary to update this record first.
                    if customerid.edit_sq != qb_cus['edit_sequence']
                        customerid.update(customer_data)
                    end
                
                else
                   
                    # the customer didn't exists so we will create
                    Customer.create(customer_data)
                    if InitialLoad == false
                        customer_created = Customer.find_by(list_id: customer_data[:list_id])
                        admin = User.where(role: "admin").select("name, email, role, id")
                        combo = User.where("role = ? or role = ?", "admin", "sales").select("name, email, role, id")
                        if qb_cus['customer_type_ref']
                            if qb_cus['customer_type_ref']['full_name'] == "Distributor"
                                combo.each do |user|
                                    Notification.create(recipient_id: user.id, action: "posted", notifiable: customer_created)
                                end
                            else
                                admin.each do |user|
                                    Notification.create(recipient_id: user.id, action: "posted", notifiable: customer_created)
                                end
                            end
                        end
                    end
                end
            end
            # let's record that this worker was ran, so that it's timestamped in logs
            # Moved the log creating to be within the handle response incase the response errors, I don't want a log.
            Log.create(worker_name: "CustomerUpdateWorker")

                # Now we will check to make sure the object isn't empty.   
        elsif !r['customer_ret'].blank? 
            c = r['customer_ret']
            customer_data = {}
            customer_data[:list_id] = c['list_id']
            customer_data[:name] = c['name']
            customer_data[:edit_sq] = c['edit_sequence']
            customer_data[:email] = c['email']
            customer_data[:qbcreate] = c['time_created']
            customer_data[:qbupdate] = c['time_modified']
             
            if c['customer_type_ref']
                customer_data[:customer_type_id] = c['customer_type_ref']['list_id']
                customer_data[:customer_type] = c['customer_type_ref']['full_name']
            end
              
            if c['sales_rep_ref']
                customer_data[:rep] = c['sales_rep_ref']['full_name']
            end
            
            if c['bill_address']
                customer_data[:address] = c['bill_address']['addr1']
                customer_data[:address2] = c['bill_address']['addr2']
                customer_data[:city] = c['bill_address']['city']
                customer_data[:state] = c['bill_address']['state']
                customer_data[:zip] = c['bill_address']['postal_code']
            end
                
            if c['ship_address']
                customer_data[:ship_address] = c['ship_address']['addr1']
                customer_data[:ship_address2] = c['ship_address']['addr2']
                customer_data[:ship_address3] = c['ship_address']['addr3']
                customer_data[:ship_address4] = c['ship_address']['addr4']
                customer_data[:ship_address5] = c['ship_address']['addr5']
                customer_data[:ship_city] = c['ship_address']['city']
                customer_data[:ship_state] = c['ship_address']['state']
                customer_data[:ship_zip] = c['ship_address']['postal_code']
            end
            
            # We are checking to see if this customer already exists
            if Customer.exists?(list_id: c['list_id'])
                customerid = Customer.find_by(list_id: customer_data[:list_id])
                    
                # we know they exists, but is it neccessary to update this record.
                if customerid.edit_sq != c['edit_sequence']
                    customerid.update(customer_data)
                end
                
            else
                # the customer didn't exists so we will create
                Customer.create(customer_data)
                if InitialLoad == false
                    customer_created = Customer.find_by(txn_id: customer_data[:txn_id])
                    admin = User.where(role: "admin").select("name, email, role, id")
                    combo = User.where("role = ? or role = ?", "admin", "sales").select("name, email, role, id")
                    if qb_cus['customer_type_ref']
                        if qb_cus['customer_type_ref']['full_name'] == "Distributor"
                            combo.each do |user|
                                Notification.create(recipient_id: user.id, action: "posted", notifiable: customer_created)
                            end
                        else
                            admin.each do |user|
                                Notification.create(recipient_id: user.id, action: "posted", notifiable: customer_created)
                            end
                        end
                    end
                end 
            end
            # let's record that this worker was ran, so that it's timestamped in logs
            # Moved the log create to be within the handle response incase the response has errors and I don't want it to log.
            Log.create(worker_name: "CustomerUpdateWorker")
        end
    end
end