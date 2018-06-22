class BillsController < ApplicationController
 before_action :authenticate_user!
 before_action :admin_only
 
 def index
        @billsdue = Bill.all.order "id ASC"
        @grouped = Bill.all.group_by {}
    end

end
