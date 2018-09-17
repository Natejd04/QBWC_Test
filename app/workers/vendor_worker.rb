require 'qbwc'
require 'concerns/qbwc_helper'
class VendorWorker < QBWC::Worker
    include QbwcHelper
        
    #We will establish which worker this is. This will be used through-out.
    WorkerName = "VendorWorker"

    # Modified this worker, you can use this to load all data, and have it continually run.
    def requests(job)
        {
            :vendor_query_rq => {
                # :xml_attributes => { "requestID" =>"1", 'iterator'  => "Start" },
                :max_returned => 100, #required
                :active_status => "ActiveOnly",
                :from_modified_date => qbwc_log_init(WorkerName),
                :to_modified_date => Date.today + (1.0)
            }
        }
    end
    

    def handle_response(r, session, job, request, data)
        # handle_response will get customers in groups of 100. When this is 0, we're done.
        # binding.pry
        complete = r['xml_attributes']['iteratorRemainingCount'] == '0'

        if r['vendor_ret'].nil? 
            # This will log if the data returned was empty and no updates occured, but it did run.
            qbwc_log_create(WorkerName, 0, "none", nil)            
        else
            # if no customer updates occured we skip this.
            # if r['vendor_ret']
            if r['vendor_ret'].is_a? Array
                i = 0
        #        We will then loop through each customer and create records.
                r['vendor_ret'].each do |qb_ven|
                    vendor_data = {}
                    vendor_data[:list_id] = qb_ven['list_id']
                    vendor_data[:name] = qb_ven['name']
                    vendor_data[:edit_sq] = qb_ven['edit_sequence']
                    vendor_data[:qb_created] = qb_ven['time_created']
                    vendor_data[:qb_modified] = qb_ven['time_modified']
                    vendor_data[:balance] = qb_ven['balance']
                    vendor_data[:email] = qb_ven['email']
                    vendor_data[:f_name] = qb_ven['first_name']
                    vendor_data[:l_name] = qb_ven['last_name']

                    if qb_ven['vendor_address']
                        vendor_data[:address1] = qb_ven['vendor_address']['addr1']
                        vendor_data[:address2] = qb_ven['vendor_address']['addr2']
                        vendor_data[:address3] = qb_ven['vendor_address']['addr3']
                        vendor_data[:address4] = qb_ven['vendor_address']['addr4']
                        vendor_data[:address5] = qb_ven['vendor_address']['addr5']
                        vendor_data[:city] = qb_ven['vendor_address']['city']
                        vendor_data[:state] = qb_ven['vendor_address']['state']
                        vendor_data[:zip] = qb_ven['vendor_address']['postal_code']
                        vendor_data[:country] = qb_ven['vendor_address']['country']
                    end

                # This is an array of objects, address later   
                    # if qb_ven['additional_contact_ref']
                    #     vendor_data[:contact_name] = qb_ven['additional_contact_ref']['contact_name']
                    #     vendor_data[:contact_value] = qb_ven['additional_contact_ref']['contact_value']
                    # end

                    if Vendor.exists?(list_id: qb_ven['list_id'])
                    vendorid = Vendor.find_by(list_id: vendor_data[:list_id])
                        
                        # We want to confirm that it's neccessary to update this record first.
                        if vendorid.edit_sq != qb_ven['edit_sequence']
                            vendorid.update(vendor_data)
                        end
                    
                    else
                       
                        # the customer didn't exists so we will create
                        Vendor.create(vendor_data)
                    
                    end
                    i += 1
                end
                qbwc_log_create(WorkerName, 0, "updates", i.to_s)

                    # Now we will check to make sure the object isn't empty.   
            elsif !r['vendor_ret'].blank? 
                    vendor_data = {}
                    qb_ven = r['vendor_ret']
                    vendor_data[:list_id] = qb_ven['list_id']
                    vendor_data[:name] = qb_ven['name']
                    vendor_data[:edit_sq] = qb_ven['edit_sequence']
                    vendor_data[:qb_created] = qb_ven['time_created']
                    vendor_data[:qb_modified] = qb_ven['time_modified']
                    vendor_data[:balance] = qb_ven['balance']
                    vendor_data[:email] = qb_ven['email']
                    vendor_data[:f_name] = qb_ven['first_name']
                    vendor_data[:l_name] = qb_ven['last_name']


                    if qb_ven['vendor_address']
                        vendor_data[:address1] = qb_ven['vendor_address']['addr1']
                        vendor_data[:address2] = qb_ven['vendor_address']['addr2']
                        vendor_data[:address3] = qb_ven['vendor_address']['addr3']
                        vendor_data[:address4] = qb_ven['vendor_address']['addr4']
                        vendor_data[:address5] = qb_ven['vendor_address']['addr5']
                        vendor_data[:city] = qb_ven['vendor_address']['city']
                        vendor_data[:state] = qb_ven['vendor_address']['state']
                        vendor_data[:zip] = qb_ven['vendor_address']['postal_code']
                        vendor_data[:country] = qb_ven['vendor_address']['country']
                    end

                # This is an array of objects, address later
                    # if qb_ven['additional_contact_ref']
                    #     vendor_data[:contact_name] = qb_ven['additional_contact_ref']['contact_name']
                    #     vendor_data[:contact_value] = qb_ven['additional_contact_ref']['contact_value']
                    # end

                    if Vendor.exists?(list_id: qb_ven['list_id'])
                    vendorid = Vendor.find_by(list_id: vendor_data[:list_id])
                        
                        # We want to confirm that it's neccessary to update this record first.
                        if vendorid.edit_sq != qb_ven['edit_sequence']
                            vendorid.update(vendor_data)
                        end
                    
                    else
                       
                        # the customer didn't exists so we will create
                        Vendor.create(vendor_data)
                    
                    end
                # let's record that this worker was ran, so that it's timestamped in logs
                # Moved the log create to be within the handle response incase the response has errors and I don't want it to log.
                qbwc_log_create(WorkerName, 0, "updates", "1")
            end
            qbwc_log_create(WorkerName, 0, "complete", nil)
        end
    end
end