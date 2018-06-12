require 'qbwc'

class JournalWorker < QBWC::Worker
    # Pre-load all customer data, only if no data exists in the Log table.
    # If data exists in the Log table, we take the last pull date as a sort filter
    # We will limit this to 1, the most recent entry
    if Log.exists?(worker_name: 'JournalWorker')

        LastUpdate = Log.where(worker_name: 'JournalWorker').order(created_at: :desc).limit(1)
        LastUpdate = LastUpdate[0][:created_at].strftime("%Y-%m-%d")
    else
        # This is preloading data based on no records in the log table
        LastUpdate = "2014-01-01"
    
    end

    # This worker will only be designed to grab the income line
    def requests(job)
        {
            :journal_entry_query_rq => {
                :xml_attributes => { "requestID" =>"1", 'iterator'  => "Start" },
                # :account_filter => {"full_name" => "Gross Sales"},
                :max_returned => 100,
                :txn_date_range_filter => {"from_txn_date" => LastUpdate, "to_txn_date" => Date.today + (1.0)},
                :include_line_items => true
            }
        }
    end
    

    def handle_response(r, session, job, request, data)
        # handle_response will get customers in groups of 100. When this is 0, we're done.
        complete = r['xml_attributes']['iteratorRemainingCount'] == '0'

        # if no customer updates occured we skip this.
        # if r['customer_ret']
        if r['journal_entry_ret'].is_a? Array
    #        We will then loop through each customer and create records.
            r['journal_entry_ret'].each do |qb_journal|
                journal_data = {}
                journal_data[:qb_edit] = qb_journal['edit_sequence']
                journal_data[:txn_id] = qb_journal['txn_id']
                journal_data[:qbcreate] = qb_journal['time_created']
                journal_data[:qbupdate] = qb_journal['time_modified']
                journal_data[:txn_number] = qb_journal['txn_number']
                journal_data[:txn_date] = qb_journal['txn_date']
                journal_data[:ref_number] = qb_journal['ref_number']
                journal_data[:account_number] = "4700"
               
                if qb_journal['currency_ref']
                    currency_ref = qb_journal['currency_ref']['full_name']
                    journal_data[:currency_ref] = qb_journal['currency_ref']['full_name']
                    journal_data[:exchange_rate] = qb_journal['exchange_rate']
                end
                
                if qb_journal['journal_debit_line']                    
                    amount = qb_journal['journal_debit_line']['amount']
                    if currency_ref == "Canadian Dollar"
                        debit = (debit * journal_data[:exchange_rate])
                    end
                    journal_data[:amount] = debit
                    journal_data[:memo] = qb_journal['journal_debit_line']['memo']

                    if qb_journal['journal_debit_line']['class_ref']
                    journal_data[:class_name] = qb_journal['journal_debit_line']['class_ref']['full_name']
                    end

                end
                
                if qb_journal['journal_credit_line']
                    amount = qb_journal['journal_credit_line']['amount']
                    if currency_ref == "Canadian Dollar"
                        credit = (credit * journal_data[:exchange_rate])
                    end
                    journal_data[:amount] = credit
                    journal_data[:memo] = qb_journal['journal_credit_line']['memo']

                    if qb_journal['journal_credit_line']['class_ref']
                    journal_data[:class_name] = qb_journal['journal_credit_line']['class_ref']['full_name']
                    end
                    
                end
              
                if Journal.exists?(txn_id: qb_journal['txn_id'])
                journalid = Journal.find_by(txn_id: journal_data[:txn_id])
                    
                    # We want to confirm that it's neccessary to update this record first.
                    if journalid.qb_edit != qb_journal['edit_sequence']
                        journalid.update(journal_data)
                    end
                
                else
                   
                    # the customer didn't exists so we will create
                    Journal.create(journal_data)
                
                end
            end
            # let's record that this worker was ran, so that it's timestamped in logs
            # Moved the log creating to be within the handle response incase the response errors, I don't want a log.
            Log.create(worker_name: "JournalWorker")

                # Now we will check to make sure the object isn't empty.   
        elsif !r['journal_entry_ret'].blank? 
            journal_data = {}
                journal_data[:qb_edit] = qb_journal['edit_sequence']
                journal_data[:txn_id] = qb_journal['txn_id']
                journal_data[:qbcreate] = qb_journal['time_created']
                journal_data[:qbupdate] = qb_journal['time_modified']
                journal_data[:txn_number] = qb_journal['txn_number']
                journal_data[:txn_date] = qb_journal['txn_date']
                journal_data[:ref_number] = qb_journal['ref_number']
                journal_data[:account_number] = "4700"
               
                if qb_journal['currency_ref']
                    currency_ref = qb_journal['currency_ref']['full_name']
                    journal_data[:currency_ref] = qb_journal['currency_ref']['full_name']
                    journal_data[:exchange_rate] = qb_journal['exchange_rate']
                end
                
                if qb_journal['journal_debit_line']
                    amount = qb_journal['journal_debit_line']['amount'] 
                    if currency_ref == "Canadian Dollar"
                        debit = (debit * journal_data[:exchange_rate])
                    end
                    journal_data[:amount] = debit
                    journal_data[:memo] = qb_journal['journal_debit_line']['memo']

                    if qb_journal['journal_debit_line']['class_ref']
                    journal_data[:class_name] = qb_journal['journal_debit_line']['class_ref']['full_name']
                    end

                end
                
                if qb_journal['journal_credit_line']
                    amount = qb_journal['journal_credit_line']['amount'] 
                    if currency_ref == "Canadian Dollar"
                        credit = (credit * journal_data[:exchange_rate])
                    end
                    journal_data[:amount] = credit
                    journal_data[:memo] = qb_journal['journal_credit_line']['memo']

                    if qb_journal['journal_credit_line']['class_ref']
                    journal_data[:class_name] = qb_journal['journal_credit_line']['class_ref']['full_name']
                    end
                end
              
                if Journal.exists?(txn_id: qb_journal['txn_id'])
                journalid = Journal.find_by(txn_id: journal_data[:txn_id])
                    
                    # We want to confirm that it's neccessary to update this record first.
                    if journalid.qb_edit != qb_journal['edit_sequence']
                        journalid.update(journal_data)
                    end
                
                else
                   
                    # the customer didn't exists so we will create
                    Journal.create(journal_data)
                
                end
            # let's record that this worker was ran, so that it's timestamped in logs
            # Moved the log creating to be within the handle response incase the response errors, I don't want a log.
            Log.create(worker_name: "JournalWorker")
        end
    end
end