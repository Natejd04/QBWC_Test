require 'qbwc'
require 'concerns/qbwc_helper'
class OrderPushWorker < QBWC::Worker
    include QbwcHelper

QBPush = Order.where("id > 8190 AND id < 8262")

    def requests(job)            
        QBPush.map do |op|
                { :txn_del_rq => {
                    :xml_attributes => { "requestID" =>"1"},
                    :txn_del_type => "SalesOrder",
                    :txn_id => op.txn_id
                }
            }
         end
    end

    def handle_response(r, session, job, request, data)
            
        if r['txn_delete_rs'].is_a? Array
            r['txn_delete_rs'].each do |qb_inv|
                Order.find_by(txn_id: qb_inv['txn_id']).destroy
            end
        end
    end
end
    

