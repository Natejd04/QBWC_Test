class TrackingsController < ApplicationController
 before_action :authenticate_user, except:[:show]

 def index
        @track = Tracking.all.order "id ASC"
        @grouped = Tracking.all.group_by {}
        @track_today = Tracking.where(:txn_date => Date.today - (1.0)).where(:emailsent => nil)
        @emailed = Tracking.where(:txn_date => Date.today - (1.0)).where.not(:emailsent => nil)
    end

 def edit
      @track = Tracking.find(params[:id]) 
    end

 def show
      @track = Tracking.find(params[:id])
    end
 def update
      respond_to do |format|
        format.html {
          @track = Tracking.find(params[:id])
          @track.update(track_params)
          redirect_to trackings_path}
        format.js
        format.json {
          @track = Tracking.find(params[:id])
          @track.update(email_params)
          render json: @track}
      end
  end

  def destroy
  	  Tracking.find(params[:id]).destroy
  	  flash[:success] = "Shipment deleted"
      redirect_to trackings_path
  end

  def email_send
    @recipients = Tracking.where(:txn_date => Date.today - (1.0)).where(:emailed => true)
    Emailer.prep_email().deliver 
    # render action: "index"
  end
    
    def email_params
      params.permit(:emailed)
  end
  def track_params
      params.require(:tracking).permit(:memo, :ship_method, :email, :emailed, :name, :packages, :ship1, :ship2, :ship3, :shipcity, :shipstate, :shippostal, :shipcountry)
  end
end
