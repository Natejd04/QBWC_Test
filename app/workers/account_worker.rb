require 'qbwc'
require 'concerns/qbwc_helper'

class AccountWorker < QBWC::Worker
    include QbwcHelper
    
#We will establish which worker this is. This will be used through-out.
    WorkerName = "AccountWorker"

#    This worker will grab only active items, in the assembly section of QB.
#    We will use this to populate our item table, so that we can refernce orders and track inventory
    def requests(job)
        {
            :account_query_rq => {
                :active_status => "ActiveOnly",
                :from_modified_date => qbwc_log_init(WorkerName),
                :to_modified_date => qbwc_log_end()
            }
        }
    end

    def handle_response(r, session, job, request, data)
        # handle_response will get customers in groups of 100. When this is 0, we're done.
        if r['account_ret'].nil? 
            # This will log if the data returned was empty and no updates occured, but it did run.
            qbwc_log_create(WorkerName, 0, "none", nil, qbwc_log_init(WorkerName), qbwc_log_end())            
        else

            # let's grab all inventory assembly items
            if r['account_ret'].is_a? Array
                i = 0

                # we will loop through each item and insert it into the Items table.
                r['account_ret'].each_with_index do |qb_account, index|
                    account_data = {}
                    account_data[:name] = qb_account['full_name']
                    
                    if qb_account['desc']
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

                    if qb_account['sublevel']
                        account_data[:sublevel] = qb_account['sublevel']
                    end


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
                        # This will record how many creates were made.
                    end
                    i += 1
                end
                qbwc_log_create(WorkerName, 0, "updates", i.to_s, qbwc_log_init(WorkerName), qbwc_log_end())

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

                if qb_account['sublevel']
                    account_data[:sublevel] = qb_account['sublevel']
                end

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
                qbwc_log_create(WorkerName, 0, "updates", "1", qbwc_log_init(WorkerName), qbwc_log_end())
            # End of the Accounts
            end
            qbwc_log_create(WorkerName, 0, "complete", nil, qbwc_log_init(WorkerName), qbwc_log_end())
            # This is the end of the empty statement
        end
    end
end