json.array! @notifications do |notification|
	# json.recipient_name notification.recipient.name
	# json.recipient_id notification.recipient.id
	json.id notification.id
	json.time notification.created_at.strftime("%m/%d at %I:%M%p")
	if notification.actor.nil?
		json.actor "Quickbooks"
	end
	if notification.actor.present?
		json.actor notification.actor
	end

	json.action notification.action
	if notification.notifiable_type == "CreditMemo"
		json.notifiable do
			json.type "#{notification.notifiable.class.to_s.underscore.humanize} from #{notification.notifiable.c_name}"
		end
		json.url credit_memo_path(notification.notifiable)
		json.type notification.notifiable_type
	
	elsif notification.notifiable_type == "Order"
		json.notifiable do
			json.type "#{notification.notifiable.class.to_s.underscore.humanize} from #{notification.notifiable.c_name}"
		end	
		json.url order_path(notification.notifiable)
		json.type notification.notifiable_type	
	
	elsif notification.notifiable_type == "Customer"
		json.notifiable do
			json.type "#{notification.notifiable.class.to_s.underscore.humanize} #{notification.notifiable.name} added"
		end	
			json.url customer_path(notification.notifiable)	
			json.type notification.notifiable_type
	end
end