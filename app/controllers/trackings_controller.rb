class TrackingsController < ApplicationController
 before_action :authenticate_user!

 def index
        @track_week = Invoice.where(:c_date => 1.week.ago..Date.today+1).where(:emailable => true, :emailed => nil)
        @emailed = Invoice.where(:c_date => 1.week.ago..Date.today+1).where(:emailable => true).where.not(:emailed => nil)
    end

 # def edit
 #      @track = Tracking.find(params[:id]) 
 #    end

 # def show
 #      @track = Tracking.find(params[:id])
 #    end
 # def update
 #      respond_to do |format|
 #        format.html {
 #          @track = Invoice.find(params[:id])
 #          @track.update(track_params)
 #          redirect_to trackings_path}
 #        format.js
 #        format.json {
 #          @track = Invoice.find(params[:id])
 #          @track.update(email_params)
 #          render json: @track}
 #      end
 #  end

  def destroy
  	  Tracking.find(params[:id]).destroy
  	  flash[:success] = "Shipment deleted"
      redirect_to trackings_path
  end

  def email_send
    @recipients = Invoice.where(:txn_date => 1.week.ago..Date.today).where(:to_email => true)
    Emailer.prep_email().deliver 
    redirect_to trackings_path, :notice => "All of your emails have been sent"
  end
    
  def email_params
      params.permit(:to_email, :emailed)
  end
  def track_params
      params.require(:tracking).permit(:memo, :tracking, :ship_method, :email, :emailed, :packages, :ship1, :ship2, :ship3, :shipcity, :shipstate, :shippostal, :shipcountry, :name, :to_email)
  end
end
