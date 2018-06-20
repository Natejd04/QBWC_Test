class Notification < ActiveRecord::Base
	belongs_to :recipient, class_name: "User", foreign_key: "recipient_id"
	belongs_to :actor, class_name: "User", foreign_key: "actor_id"
	belongs_to :notifiable, polymorphic: true

	scope :unread, ->{ where(read_at: nil) }
end
