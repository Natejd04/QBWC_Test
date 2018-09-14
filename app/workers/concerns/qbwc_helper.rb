module QbwcHelper
  	def qbwc_log_init(log_name)
	    if Log.exists?(worker_name: log_name)
	      	if Log.where(worker_name: log_name).where(status: 'Completed').order(created_at: :desc).limit(1).nil? || Log.where(worker_name: log_name).where(status: 'Completed').order(created_at: :desc).limit(1).empty?
	            Log.where(worker_name: log_name).order(created_at: :desc).limit(1)[0][:created_at].strftime("%Y-%m-%d") 
	        else
	      		Log.where(worker_name: log_name).where(status: 'Completed').order(created_at: :desc).limit(1)[0][:created_at].strftime("%Y-%m-%d")
	      	end
	    else
	      # This is preloading data based on no records in the log table
	      # This is arbitrary and a system for loading in batches from the start should be implemented.
	      3.month.ago.strftime("%Y-%m-%d")
	    end
	end

	def qbwc_log_create(worker, stat, msg)
		if stat == "none"
			Log.create(worker_name: WorkerName, status: "No Changes")
		elsif stat == "updates"
			Log.create(worker_name: WorkerName, status: stat, log_msg: msg + "record(s) were updated")
		elsif stat == "completed"
			Log.create(worker_name: WorkerName, status: "Completed")
		end
	end
end