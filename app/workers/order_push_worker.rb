require 'qbwc'

class OrderPushWorker < QBWC::Worker

 def requests(job)
        {
            :sales_order_add_rq => {
            	:xml_attributes => { "requestID" =>"1"},
            	:sales_order_add => {
	                :customer_ref => {"list_id" => "80000B69-1402348608", "full_name" => "Nate2 Davis"},
	                :sales_order_line_add => {
	                	"desc" => "PoopStick"
	                }
            	}
        	}
        }
    end

    def handle_response(r, session, job, request, data)

    	# request={}
    	# data['customer_ref']['list_id'] = "80000B69-1402348608"
    	# data['po_number'] = "TEST"    
    	Log.create(worker_name: r)

    end
end

