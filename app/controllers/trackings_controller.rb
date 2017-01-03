class TrackingsController < ApplicationController
 
 def index
        @track = Tracking.all.order "id ASC"
        @grouped = Tracking.all.group_by {}
        @track_today = Tracking.where(:txn_date => Date.today)
    end

 def edit
      @track = Tracking.find(params[:id]) 
    end

 def show
      @track = Tracking.find(params[:id])
    end
 def update
      @track = Tracking.find(params[:id])
      @track.update(track_params)
      p @track
      @track_today = Tracking.where(:txn_date => Date.today)
      render action: "index"
  end
    
    def track_params
      params.require(:tracking).permit(:memo, :ship_method, :email, :emailed)
  end
end
