class BillsController < ApplicationController
 
 def index
        @billsdue = Bill.all.order "id ASC"
    end

end
