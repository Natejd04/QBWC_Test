class Emailer < ActionMailer::Base
	default from: "natejd05@gmail.com"


	# def sample_email(recipient)

 #   		end
   	
 #   	end

   def sample_email(recipient)
     mail(to: recipient.email, subject: "Test Email")
   end
end
