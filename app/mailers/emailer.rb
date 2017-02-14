class Emailer < ActionMailer::Base
	default from: "shipping@zingbars.com"


	def prep_email()
		@recipients = Tracking.where(:txn_date => Date.today).where(:emailed => true, :emailsent => nil)
     	@recipients.each do |recipient|
       		@name = recipient.name
       		Emailer.sample_email(recipient).deliver
          recipient.update_attribute(:emailsent, Time.now)
    	end
 	end
   	

   def sample_email(recipient)
   	@recipient = recipient
     mail(to: recipient.email, subject: "Shipping Confirmation")
   end
end
