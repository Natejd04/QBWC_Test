class InvoicesController < ApplicationController
	before_action :authenticate_user!
	before_action :admin_only, :ops_only, except:[:show, :index]

	def index
		@invoices = Invoice.all.order "id ASC"
    	@inv1 = Invoice.where("c_date >= ?", 2.months.ago).paginate(:page => params[:page], :per_page => 50).order('c_date ASC')
      @invoice_limit = Invoice.where("c_date >= ?", 3.months.ago)

    respond_to do |format|
      format.html
      format.csv { send_data Invoice.inv_csv(@invoice_limit), filename: "invoices-#{Time.now.strftime("%d-%m-%Y %k%M")}.csv" }
    end    
	end

	def show
      @order = Invoice.find(params[:id])
  	end
  	def update
	  	respond_to do |format|
        format.html {
          @track = Invoice.find(params[:id])
          @track.update(track_params)
          redirect_to trackings_path}
        format.js
        format.json {
          @track = Invoice.find(params[:id])
          @track.update(email_params)
          render json: @track}
      end
    end

  	def email_params
      params.permit(:to_email, :emailed)
 	end
 	 def track_params
      params.require(:tracking).permit(:memo, :tracking, :ship_method, :email, :emailed, :packages, :ship1, :ship2, :ship3, :shipcity, :shipstate, :shippostal, :shipcountry, :name, :to_email)
  end

end
