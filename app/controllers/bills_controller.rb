class BillsController < ApplicationController
 
 def index
        @billsdue = Bill.all.order "id ASC"
        @grouped = Bill.all.group_by {}
    end

end
