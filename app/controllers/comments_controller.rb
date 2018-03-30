class CommentsController < ApplicationController

	def create 
		@order = Order.find(params[:order_id]) 
		@comment = @order.comments.create(comment_params) 
		redirect_to order_path(@order) 
	end 

	private 
		def comment_params 
			params.require(:comment). permit(:user_id, :body, :order_id, :customer_id) 
	end




end
