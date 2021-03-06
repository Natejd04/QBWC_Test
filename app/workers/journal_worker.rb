require 'qbwc'
require 'concerns/qbwc_helper'
class JournalWorker < QBWC::Worker
    include QbwcHelper

    #We will establish which worker this is. This will be used through-out.
    WorkerName = "JournalWorker"
    
    # This worker will only be designed to grab the income line
    def requests(job)
        {
            :journal_entry_query_rq => {
                # :max_returned => 100,
                # :xml_attributes => { "requestID" =>"1", 'iterator'  => "Start" },
                :modified_date_range_filter => {"from_modified_date" => qbwc_log_init(WorkerName), "to_modified_date" => qbwc_log_end()},
                :include_line_items => true
            }
        }
    end
    

    def handle_response(r, session, job, request, data)
        # handle_response will get journals in groups of 100. When this is 0, we're done.
        complete = r['xml_attributes']['iteratorRemainingCount'] == '0'

        if r['journal_entry_ret'].nil? 
            # This will log if the data returned was empty and no updates occured, but it did run.
            qbwc_log_create(WorkerName, 0, "none", nil, qbwc_log_init(WorkerName), qbwc_log_end())            
        else
        # if no journal updates occured we skip this.
            if r['journal_entry_ret'].is_a? Array
                i = 0
        #        We will then loop through each journal and create/update records.
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
                    
                    if Journal.exists?(txn_id: qb_journal['txn_id'])
                        journalid = Journal.find_by(txn_id: journal_data[:txn_id])
                        
                        # We want to confirm that it's neccessary to update this record first.
                        if journalid.qb_edit != qb_journal['edit_sequence']
                            journalid.update(journal_data)
                            parent_updated = true
                        end
                    
                    else
                       
                        # the customer didn't exists so we will create
                        Journal.create(journal_data)
                    
                    end



    # ----------------> Start Account Line Item for debit
                    # Line items are recorded if they are an array
                    if qb_journal['journal_debit_line'].is_a? Array
                        
                        qb_journal['journal_debit_line'].each do |li|
                        
                        li_data = {}

                            # We just recorded it and could pull it via find.
                            journalid = Journal.find_by(txn_id: qb_journal['txn_id'])
                            li_data[:journal_id] = journalid.id

                            li_data[:txn_id] = li['txn_line_id']

                            if li['account_ref']
                                # This line item has an accont, let's find it
                                if Account.exists?(list_id: li['account_ref']['list_id'])
                                    li_data[:account_id] = Account.find_by(list_id: li['account_ref']['list_id']).id
                                end
                            end

                            # Entity Reference - Customer
                            if li['entity_ref']
                                # This line item might have an entity (customer) has an accont, let's find it
                                if Customer.exists?(list_id: li['entity_ref']['list_id'])
                                    li_data[:customer_id] = Customer.find_by(list_id: li['entity_ref']['list_id']).id
                                end
                            end

                            # Entity Reference - Vendor
                            if li['entity_ref']
                                # This line item might have an entity (customer) has an accont, let's find it
                                if Vendor.exists?(list_id: li['entity_ref']['list_id'])
                                    li_data[:vendor_id] = Vendor.find_by(list_id: li['entity_ref']['list_id']).id
                                end
                            end

                            li_data[:account_type] = "debit"
                            amount = li['amount']
                                if currency_ref == "Canadian Dollar"
                                    if !li_data[:amount].nil?
                                        li_data[:amount] = (amount * journal_data[:exchange_rate]).round(2)
                                    else
                                        li_data[:amount] = amount
                                    end
                                else
                                    li_data[:amount] = amount
                                end
                            
                            li_data[:memo] = li['memo']

                                if li['class_ref']
                                    li_data[:class_name] = li['class_ref']['full_name']
                                end
                        
                                             # Now we need to record these line items
                            if AccountLineItem.exists?(txn_id: li['txn_line_id'])
                                lineitemupdate = AccountLineItem.find_by(txn_id: li['txn_line_id'])
                                # Has this LineItem actually been modified?

                                if parent_updated == true
                                    lineitemupdate.update(li_data)
                                end
                            else
                                AccountLineItem.create(li_data)
                            end

                        end

                     # we need this if the line item only has one entry.   
                    elsif !qb_journal['journal_debit_line'].blank? 
                        li = qb_journal['journal_debit_line']
                        li_data = {}

                        # We just recorded it and could pull it via find.
                        journalid = Journal.find_by(txn_id: qb_journal['txn_id'])
                        li_data[:journal_id] = journalid.id

                        li_data[:txn_id] = li['txn_line_id']

                        if li['account_ref']
                            # This line item has an accont, let's find it
                            if Account.exists?(list_id: li['account_ref']['list_id'])
                                li_data[:account_id] = Account.find_by(list_id: li['account_ref']['list_id']).id
                            end
                        end

                        # Entity Reference - Customer
                        if li['entity_ref']
                            # This line item might have an entity (customer) has an accont, let's find it
                            if Customer.exists?(list_id: li['entity_ref']['list_id'])
                                li_data[:customer_id] = Customer.find_by(list_id: li['entity_ref']['list_id']).id
                            end
                        end

                        # Entity Reference - Vendor
                        if li['entity_ref']
                            # This line item might have an entity (customer) has an accont, let's find it
                            if Vendor.exists?(list_id: li['entity_ref']['list_id'])
                                li_data[:vendor_id] = Vendor.find_by(list_id: li['entity_ref']['list_id']).id
                            end
                        end

                        li_data[:account_type] = "debit"
                        amount = li['amount']
                            if currency_ref == "Canadian Dollar"
                                if !li_data[:amount].nil?
                                        li_data[:amount] = (amount * journal_data[:exchange_rate]).round(2)
                                    else
                                        li_data[:amount] = amount
                                    end
                            else
                                li_data[:amount] = amount
                            end

                        li_data[:memo] = li['memo']

                            if li['class_ref']
                                li_data[:class_name] = li['class_ref']['full_name']
                            end
                    
                                         # Now we need to record these line items
                        if AccountLineItem.exists?(txn_id: li['txn_line_id'])
                            lineitemupdate = AccountLineItem.find_by(txn_id: li['txn_line_id'])
                            # Has this LineItem actually been modified?

                            if parent_updated == true
                                lineitemupdate.update(li_data)
                            end


                        else
                            AccountLineItem.create(li_data)
                        end
                    end
    # ---------------> This is the end of the Debit Line Item section

    # ----------------> Start Account Line Item for credit
                    # Line items are recorded if they are an array
                    if qb_journal['journal_credit_line'].is_a? Array
                        
                        qb_journal['journal_credit_line'].each do |li|
                        
                            li_data = {}

                            # We just recorded it and could pull it via find.
                            li_data[:journal_id] = Journal.find_by(txn_id: qb_journal['txn_id']).id

                            li_data[:txn_id] = li['txn_line_id']

                            if li['account_ref']
                                # This line item has an accont, let's find it
                                if Account.exists?(list_id: li['account_ref']['list_id'])
                                    li_data[:account_id] = Account.find_by(list_id: li['account_ref']['list_id']).id
                                end
                            end

                            # Entity Reference - Customer
                            if li['entity_ref']
                                # This line item might have an entity (customer) has an accont, let's find it
                                if Customer.exists?(list_id: li['entity_ref']['list_id'])
                                    li_data[:customer_id] = Customer.find_by(list_id: li['entity_ref']['list_id']).id
                                end
                            end

                            # Entity Reference - Vendor
                            if li['entity_ref']
                                # This line item might have an entity (customer) has an accont, let's find it
                                if Vendor.exists?(list_id: li['entity_ref']['list_id'])
                                    li_data[:vendor_id] = Vendor.find_by(list_id: li['entity_ref']['list_id']).id
                                end
                            end

                            li_data[:account_type] = "credit"
                            amount = li['amount']
                                if currency_ref == "Canadian Dollar"
                                    if !li_data[:amount].nil?
                                        li_data[:amount] = (amount * journal_data[:exchange_rate]).round(2)
                                    else
                                        li_data[:amount] = amount
                                    end
                                else
                                    li_data[:amount] = amount
                                end

                            li_data[:memo] = li['memo']

                                if li['class_ref']
                                    li_data[:class_name] = li['class_ref']['full_name']
                                end
                        
                                             # Now we need to record these line items
                            if AccountLineItem.exists?(txn_id: li['txn_line_id'])
                                lineitemupdate = AccountLineItem.find_by(txn_id: li['txn_line_id'])
                                # Has this LineItem actually been modified?

                                if parent_updated == true
                                    lineitemupdate.update(li_data)
                                end
                            else
                                AccountLineItem.create(li_data)
                            end

                        end

                     # we need this if the line item only has one entry.   
                    elsif !qb_journal['journal_credit_line'].blank? 
                        li = qb_journal['journal_credit_line']
                        li_data = {}

                        # We just recorded it and could pull it via find.
                        journalid = Journal.find_by(txn_id: qb_journal['txn_id'])
                        li_data[:journal_id] = journalid.id

                        li_data[:txn_id] = li['txn_line_id']

                        if li['account_ref']
                            # This line item has an accont, let's find it
                            if Account.exists?(list_id: li['account_ref']['list_id'])
                                li_data[:account_id] = Account.find_by(list_id: li['account_ref']['list_id']).id
                            end
                        end

                        # Entity Reference - Customer
                        if li['entity_ref']
                            # This line item might have an entity (customer) has an accont, let's find it
                            if Customer.exists?(list_id: li['entity_ref']['list_id'])
                                li_data[:customer_id] = Customer.find_by(list_id: li['entity_ref']['list_id']).id
                            end
                        end

                        # Entity Reference - Vendor
                        if li['entity_ref']
                            # This line item might have an entity (customer) has an accont, let's find it
                            if Vendor.exists?(list_id: li['entity_ref']['list_id'])
                                li_data[:vendor_id] = Vendor.find_by(list_id: li['entity_ref']['list_id']).id
                            end
                        end

                        li_data[:account_type] = "credit"
                        amount = li['amount']
                            if currency_ref == "Canadian Dollar"
                                 if !li_data[:amount].nil?
                                        li_data[:amount] = (amount * journal_data[:exchange_rate]).round(2)
                                    else
                                        li_data[:amount] = amount
                                    end
                            else
                                li_data[:amount] = amount
                            end
                        
                        li_data[:memo] = li['memo']

                            if li['class_ref']
                                li_data[:class_name] = li['class_ref']['full_name']
                            end
                    
                                         # Now we need to record these line items
                        if AccountLineItem.exists?(txn_id: li['txn_line_id'])
                            lineitemupdate = AccountLineItem.find_by(txn_id: li['txn_line_id'])
                            # Has this LineItem actually been modified?

                            if parent_updated == true
                                lineitemupdate.update(li_data)
                            end
                        else
                            AccountLineItem.create(li_data)
                        end
    # ----------------> End of credit account line item entry 
                    end
                
    # ----------------> End of Journal Entry each loop
                    i += 1
                    end
                    qbwc_log_create(WorkerName, 0, "updates", i.to_s, qbwc_log_init(WorkerName), qbwc_log_end())
                    # Now we will check to make sure the object isn't empty.   
            elsif !r['journal_entry_ret'].blank? 
                journal_data = {}
                qb_journal = r['journal_entry_ret']
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
              
                if Journal.exists?(txn_id: qb_journal['txn_id'])
                journalid = Journal.find_by(txn_id: journal_data[:txn_id])
                    
                    # We want to confirm that it's neccessary to update this record first.
                    if journalid.qb_edit != qb_journal['edit_sequence']
                        journalid.update(journal_data)
                        parent_updated = true
                    end
                else
                    # the customer didn't exists so we will create
                    Journal.create(journal_data)
                end
                
    # ----------------> Start Account Line Item for debit
                # Line items are recorded if they are an array
                if qb_journal['journal_debit_line'].is_a? Array
                    
                    qb_journal['journal_debit_line'].each do |li|
                    
                        li_data = {}

                        # We just recorded it and could pull it via find.
                        journalid = Journal.find_by(txn_id: qb_journal['txn_id'])
                        li_data[:journal_id] = journalid.id

                        li_data[:txn_id] = li['txn_line_id']

                        if li['account_ref']
                            # This line item has an accont, let's find it
                            if Account.exists?(list_id: li['account_ref']['list_id'])
                                li_data[:account_id] = Account.find_by(list_id: li['account_ref']['list_id']).id
                            end
                        end

                        # Entity Reference - Customer
                        if li['entity_ref']
                            # This line item might have an entity (customer) has an accont, let's find it
                            if Customer.exists?(list_id: li['entity_ref']['list_id'])
                                li_data[:customer_id] = Customer.find_by(list_id: li['entity_ref']['list_id']).id
                            end
                        end

                        # Entity Reference - Vendor
                        if li['entity_ref']
                            # This line item might have an entity (customer) has an accont, let's find it
                            if Vendor.exists?(list_id: li['entity_ref']['list_id'])
                                li_data[:vendor_id] = Vendor.find_by(list_id: li['entity_ref']['list_id']).id
                            end
                        end

                        li_data[:account_type] = "debit"
                        amount = li['amount']
                            if currency_ref == "Canadian Dollar"
                                li_data[:amount] = (amount * journal_data[:exchange_rate]).round(2)
                            else
                                li_data[:amount] = amount
                            end

                        li_data[:memo] = li['memo']

                            if li['class_ref']
                                li_data[:class_name] = li['class_ref']['full_name']
                            end
                    
                                         # Now we need to record these line items
                        if AccountLineItem.exists?(txn_id: li['txn_line_id'])
                            lineitemupdate = AccountLineItem.find_by(txn_id: li['txn_line_id'])
                            # Has this LineItem actually been modified?

                            if parent_updated == true
                                lineitemupdate.update(li_data)
                            end
                        else
                            AccountLineItem.create(li_data)
                        end

                    end

                 # we need this if the line item only has one entry.   
                elsif !qb_journal['journal_debit_line'].blank? 
                    li = qb_journal['journal_debit_line']
                    li_data = {}

                    # We just recorded it and could pull it via find.
                    journalid = Journal.find_by(txn_id: qb_journal['txn_id'])
                    li_data[:journal_id] = journalid.id

                    li_data[:txn_id] = li['txn_line_id']

                    if li['account_ref']
                        # This line item has an accont, let's find it
                        if Account.exists?(list_id: li['account_ref']['list_id'])
                            li_data[:account_id] = Account.find_by(list_id: li['account_ref']['list_id']).id
                        end
                    end

                    # Entity Reference - Customer
                    if li['entity_ref']
                        # This line item might have an entity (customer) has an accont, let's find it
                        if Customer.exists?(list_id: li['entity_ref']['list_id'])
                            li_data[:customer_id] = Customer.find_by(list_id: li['entity_ref']['list_id']).id
                        end
                    end

                    # Entity Reference - Vendor
                    if li['entity_ref']
                        # This line item might have an entity (customer) has an accont, let's find it
                        if Vendor.exists?(list_id: li['entity_ref']['list_id'])
                            li_data[:vendor_id] = Vendor.find_by(list_id: li['entity_ref']['list_id']).id
                        end
                    end

                    li_data[:account_type] = "debit"
                    amount = li['amount']
                        if currency_ref == "Canadian Dollar"
                            li_data[:amount] = (amount * journal_data[:exchange_rate]).round(2)
                        else
                            li_data[:amount] = amount
                        end

                    li_data[:memo] = li['memo']

                        if li['class_ref']
                            li_data[:class_name] = li['class_ref']['full_name']
                        end
                
                                     # Now we need to record these line items
                    if AccountLineItem.exists?(txn_id: li['txn_line_id'])
                        lineitemupdate = AccountLineItem.find_by(txn_id: li['txn_line_id'])
                        # Has this LineItem actually been modified?

                        if parent_updated == true
                            lineitemupdate.update(li_data)
                        end
                    else
                        AccountLineItem.create(li_data)
                    end
                end
    # ---------------> This is the end of the Debit Line Item section

    # ----------------> Start Account Line Item for credit
                # Line items are recorded if they are an array
                if qb_journal['journal_credit_line'].is_a? Array
                    
                    qb_journal['journal_credit_line'].each do |li|
                    
                        li_data = {}

                        # We just recorded it and could pull it via find.
                        journalid = Journal.find_by(txn_id: qb_journal['txn_id'])
                        li_data[:journal_id] = journalid.id

                        li_data[:txn_id] = li['txn_line_id']

                        if li['account_ref']
                            # This line item has an accont, let's find it
                            if Account.exists?(list_id: li['account_ref']['list_id'])
                                li_data[:account_id] = Account.find_by(list_id: li['account_ref']['list_id']).id
                            end
                        end

                        # Entity Reference - Customer
                        if li['entity_ref']
                            # This line item might have an entity (customer) has an accont, let's find it
                            if Customer.exists?(list_id: li['entity_ref']['list_id'])
                                li_data[:customer_id] = Customer.find_by(list_id: li['entity_ref']['list_id']).id
                            end
                        end

                        # Entity Reference - Vendor
                        if li['entity_ref']
                            # This line item might have an entity (customer) has an accont, let's find it
                            if Vendor.exists?(list_id: li['entity_ref']['list_id'])
                                li_data[:vendor_id] = Vendor.find_by(list_id: li['entity_ref']['list_id']).id
                            end
                        end

                        li_data[:account_type] = "credit"
                        amount = li['amount']
                            if currency_ref == "Canadian Dollar"
                                li_data[:amount] = (amount * journal_data[:exchange_rate]).round(2)
                            else
                                li_data[:amount] = amount
                            end
                        
                        li_data[:memo] = li['memo']

                            if li['class_ref']
                                li_data[:class_name] = li['class_ref']['full_name']
                            end
                    
                                         # Now we need to record these line items
                        if AccountLineItem.exists?(txn_id: li['txn_line_id'])
                            lineitemupdate = AccountLineItem.find_by(txn_id: li['txn_line_id'])
                            # Has this LineItem actually been modified?

                            if parent_updated == true
                                lineitemupdate.update(li_data)
                            end
                        else
                            AccountLineItem.create(li_data)
                        end

                    end

                 # we need this if the line item only has one entry.   
                elsif !qb_journal['journal_credit_line'].blank? 
                    li = qb_journal['journal_credit_line']
                    li_data = {}

                    # We just recorded it and could pull it via find.
                    journalid = Journal.find_by(txn_id: qb_journal['txn_id'])
                    li_data[:journal_id] = journalid.id

                    li_data[:txn_id] = li['txn_line_id']

                    if li['account_ref']
                        # This line item has an accont, let's find it
                        if Account.exists?(list_id: li['account_ref']['list_id'])
                            li_data[:account_id] = Account.find_by(list_id: li['account_ref']['list_id']).id
                        end
                    end

                    # Entity Reference - Customer
                    if li['entity_ref']
                        # This line item might have an entity (customer) has an accont, let's find it
                        if Customer.exists?(list_id: li['entity_ref']['list_id'])
                            li_data[:customer_id] = Customer.find_by(list_id: li['entity_ref']['list_id']).id
                        end
                    end

                    # Entity Reference - Vendor
                    if li['entity_ref']
                        # This line item might have an entity (customer) has an accont, let's find it
                        if Vendor.exists?(list_id: li['entity_ref']['list_id'])
                            li_data[:vendor_id] = Vendor.find_by(list_id: li['entity_ref']['list_id']).id
                        end
                    end

                    li_data[:account_type] = "credit"
                    amount = li['amount']
                        if currency_ref == "Canadian Dollar"
                            li_data[:amount] = (amount * journal_data[:exchange_rate]).round(2)
                        else
                            li_data[:amount] = amount
                        end
                   
                   li_data[:memo] = li['memo']

                        if li['class_ref']
                            li_data[:class_name] = li['class_ref']['full_name']
                        end
                
                                     # Now we need to record these line items
                    if AccountLineItem.exists?(txn_id: li['txn_line_id'])
                        lineitemupdate = AccountLineItem.find_by(txn_id: li['txn_line_id'])
                        # Has this LineItem actually been modified?

                        if parent_updated == true
                            lineitemupdate.update(li_data)
                        end
                    else
                        AccountLineItem.create(li_data)
                    end
    # ----------------> End of credit account line item entry 
                end
                qbwc_log_create(WorkerName, 0, "updates", "1", qbwc_log_init(WorkerName), qbwc_log_end())
    #----------------> End of non-array journal update
            end
            qbwc_log_create(WorkerName, 0, "complete", nil, qbwc_log_init(WorkerName), qbwc_log_end())
        end
    end
end