require 'qbwc'


class AccountWorker < QBWC::Worker

# Same thing, let's fine out the last time this was pulled, and decide if it's worth it
    if Log.exists?(worker_name: 'AccountWorker')

        LastUpdate = Log.where(worker_name: 'AccountWorker').order(created_at: :desc).limit(1)
        LastUpdate = LastUpdate[0][:created_at].strftime("%Y-%m-%d")
    else
        # This is preloading data based on no records in the log table
        LastUpdate = "2000-01-01"
    
    end

#    This worker will grab only active items, in the assembly section of QB.
#    We will use this to populate our item table, so that we can refernce orders and track inventory
    def requests(job)
        {
            :account_query_rq => {
                :active_status => "ActiveOnly",
                :from_modified_date => LastUpdate,
                :to_modified_date => Date.today + (1.0)
            }
        }
    end

    def handle_response(r, session, job, request, data)
        # handle_response will get customers in groups of 100. When this is 0, we're done.
        # complete = r['xml_attributes']['iteratorRemainingCount'] == '0'
        # binding.pry
        # let's grab all inventory assembly items
        if r['account_ret'].is_a? Array

            # we will loop through each item and insert it into the Items table.
            r['account_ret'].each do |qb_account|
                account_data = {}
                account_data[:name] = qb_account['full_name']
                
                if account_data[:description] = qb_account['desc']
                    account_data[:description] = qb_account['desc']
                end

                account_data[:number] = qb_account['account_number']
                account_data[:account_type] = qb_account['account_type']
                account_data[:balance] = qb_account['balance']
                account_data[:list_id] = qb_account['list_id']
                account_data[:edit_sq] = qb_account['edit_sequence']
                account_data[:active] = qb_account['is_active']
                account_data[:qb_created] = qb_account['time_created']
                account_data[:qb_modified] = qb_account['time_modified']


                if qb_account['currency_ref']                    
                    account_data[:currency] = qb_account['currency_ref']['full_name']
                end
               
                if Account.exists?(list_id: qb_account['list_id'])
                    accountupdate = Account.find_by(list_id: qb_account['list_id'])
                    # before updating, lets find out if it's neccessary by filtering by modified
                    if accountupdate.edit_sq != qb_account['edit_sequence']
                        accountupdate.update(account_data)
                    end
                else
                    Account.create(account_data)
                end
            end

        # This is if there is only 1 item update
        elsif !r['account_ret'].blank? 
            qb_account = r['account_ret']
            account_data = {}
                account_data[:name] = qb_account['full_name']
                account_data[:description] = qb_account['desc']
                account_data[:number] = qb_account['account_number']
                account_data[:account_type] = qb_account['account_type']
                account_data[:balance] = qb_account['balance']
                account_data[:list_id] = qb_account['list_id']
                account_data[:edit_sq] = qb_account['edit_sequence']
                account_data[:active] = qb_account['is_active']
                account_data[:qb_created] = qb_account['time_created']
                account_data[:qb_modified] = qb_account['time_modified']


                if qb_account['currency_ref']                    
                    account_data[:currency] = qb_account['currency_ref']['full_name']
                end
               
                if Account.exists?(list_id: qb_account['list_id'])
                    accountupdate = Account.find_by(list_id: qb_account['list_id'])
                    # before updating, lets find out if it's neccessary by filtering by modified
                    if accountupdate.edit_sq != qb_account['edit_sequence']
                        accountupdate.update(account_data)
                    end
                else
                    Account.create(account_data)
                end
        # End of the Accounts
        end
        Log.create(worker_name: "AccountWorker")

    end
end