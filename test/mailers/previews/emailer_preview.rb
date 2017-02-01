# Preview all emails at http://localhost:3000/rails/mailers/emailer
class EmailerPreview < ActionMailer::Preview

	def sample_mail_preview
		@recipients = Tracking.last
    	Emailer.sample_email(@recipients)
  	end

end
