json.array! @notifications do |notification|
	# json.recipient_name notification.recipient.name
	# json.recipient_id notification.recipient.id
	json.id notification.id
	if notification.actor.nil?
		json.actor "Quickbooks"
	end
	if notification.actor.present?
		json.actor notification.actor
	end

	json.action notification.action
	json.notifiable do
		json.type "a new #{notification.notifiable.class.to_s.underscore.humanize.downcase}"
	end
		json.url order_path(notification.notifiable)
end