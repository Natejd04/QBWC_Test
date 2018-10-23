class ApiHook < ActiveRecord::Base
	before_validation(on: :create) do
      generate_auth_key
    end
    before_save :encrypt_token

private
	def salty(len=20)
		chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
      	salty = ''
      	1.upto(len) { |i| salty << chars[rand(chars.size-1)] }
      	self.salt = salty

    end

    def generate_auth_key
    	self.auth_key = Digest::SHA2.hexdigest("#{salty}#{Time.now.utc}")
    end

 	def encrypt_token
        #encrypt me some yummy password and store that info
        self.token = encrypt(token)
    end

    #encrypt password with salt and enjoy.
    def encrypt(toke)
        Digest::SHA2.hexdigest("#{salty}#{toke}")
    end

end
