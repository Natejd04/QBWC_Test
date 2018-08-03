class Emailer < ActionMailer::Base
	default from: "shipping@zingbars.com"


	def prep_email()
		@recipients = Invoice.where(:c_date => 1.week.ago..Date.today+1).where(:emailable => true, :to_email => true)
     	@recipients.each do |recipient|
       		@name = recipient.c_name
       		Emailer.sample_email(recipient).deliver
          recipient.update_attributes(:emailed => Time.now, :to_email => false)
    	end
 	end
   	

   def sample_email(recipient)
   	@recipient = recipient
     mail(to: recipient.email, subject: "Shipping Confirmation")
   end
end
