module QbwcHelper
  	def initial_load()
  		QbHelper.first.initial_load
  	end

  	def qbwc_log_init(log_name)
  		if initial_load == false
		    if Log.exists?(worker_name: log_name)
		      	if Log.where(worker_name: log_name).where(status: 'Completed', initial_load: false).order(created_at: :desc).limit(1).nil? || Log.where(worker_name: log_name).where(status: 'Completed', initial_load: false).order(created_at: :desc).limit(1).empty?
		            Log.where(worker_name: log_name).order(created_at: :desc).limit(1)[0][:created_at].strftime("%Y-%m-%d") 
		        else
		      		Log.where(worker_name: log_name).where(status: 'Completed', initial_load: false).order(created_at: :desc).limit(1)[0][:created_at].strftime("%Y-%m-%d")
		      	end
		    else
		      # This is preloading data based on no records in the log table
		      # This is arbitrary and a system for loading in batches from the start should be implemented.
		      3.month.ago.strftime('%Y-%m-%d')
		    end
		else
			# We can force the start date range here, as long as initial_load is toggled to true
			QbHelper.first.start.strftime('%Y-%m-%d')
		end
	end

	def qbwc_log_end()
		if initial_load == false
			Date.today + (1.0)
		else
			# we can set the end range date here, as long as initial_load is toggled to true
			QbHelper.first.end.strftime('%Y-%m-%d')
		end
	end

	def qbwc_log_create(worker, code, stat, msg, startd, endd)
		if stat == "none" && code == 0 
			Log.create(worker_name: worker, status: "Completed", log_msg: "No changes were made", start_date: startd, end_date: endd, initial_load: initial_load())
		elsif stat == "none" && code == 1
			Log.create(worker_name: worker, status: "Completed", log_msg: msg, start_date: startd, end_date: endd, initial_load: initial_load())
		elsif stat == "updates" && code == 0
			Log.create(worker_name: worker, status: "Updates", log_msg: msg + " record(s) were updated or created", start_date: startd, end_date: endd, initial_load: initial_load())
		elsif stat == "updates" && code == 1
			Log.create(worker_name: worker, status: "Updates", log_msg: msg, start_date: startd, end_date: endd, initial_load: initial_load())
		elsif stat == "complete"
			Log.create(worker_name: worker, status: "Completed", log_msg: "Changes were made", start_date: startd, end_date: endd, initial_load: initial_load())
		end
	end
end