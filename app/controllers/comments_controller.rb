class CommentsController < ApplicationController
before_action :authenticate_user!
	def create 
		@order = Order.find(params[:order_id]) 
		@comment = @order.comments.create(comment_params) 
		@comment.user = current_user
		
		# if @comment.save			
			
		# 	# This is for creating the notifications
			

		# end
		
		redirect_to order_path(@order) 
	end 

	private 
		def comment_params 
			params.require(:comment). permit(:user_id, :body, :order_id, :customer_id) 
	end




end
