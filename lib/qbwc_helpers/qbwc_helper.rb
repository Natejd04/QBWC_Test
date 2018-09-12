module QbwcHelper
  	def qbwc_log_init(log_name)
	    if Log.exists?(worker_name: log_name)
	      	if Log.where(worker_name: log_name).where(status: 'Completed').order(created_at: :desc).limit(1).nil? || Log.where(worker_name: log_name).where(status: 'Completed').order(created_at: :desc).limit(1).empty?
	              Log.where(worker_name: log_name).order(created_at: :desc).limit(1)[0][:created_at].strftime("%Y-%m-%d") 
	          end
	      Log.where(worker_name: log_name).where(status: 'Completed').order(created_at: :desc).limit(1)[0][:created_at].strftime("%Y-%m-%d")
	    else
	      # This is preloading data based on no records in the log table
	      3.month.ago.strftime("%Y-%m-%d")
	    end
	end
end