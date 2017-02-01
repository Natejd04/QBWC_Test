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

  def destroy
  	  Tracking.find(params[:id]).destroy
  	  flash[:success] = "Shipment deleted"
      render action: "index"
  end

  def email_send
    # @recipient = Tracking.last
    # Emailer.sample_email(@recipient).deliver
     @recipients = Tracking.where(:txn_date => Date.today)
     @recipients.each do |recipient|
       @name = recipient.name
       Emailer.sample_email(recipient).deliver
    end
    render action: "index"
  end
    
    def track_params
      params.require(:tracking).permit(:memo, :ship_method, :email, :emailed)
  end
end
