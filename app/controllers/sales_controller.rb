class SalesController < ApplicationController
	before_action :authenticate_user
end
