class TrackingsController < ApplicationController
 
 def index
        @track = Tracking.all.order "id ASC"
        @grouped = Tracking.all.group_by {}
        @track_today = Tracking.where(:time_created => Date.today)
    end

end
