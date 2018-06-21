class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable, :timeoutable
         
    has_many :recipients, class_name: "Notification", foreign_key: "recipient_id"
    has_many :actors, class_name: "Notification", foreign_key: "actor_id"
    has_many :notifications 
#     attr_accessor :password
# #    attr_accessible :name, :email, :password, :password_confirmation

#     email_regex = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

#     validates   :name,      :presence   => true,
#                 :length                 => { :maximum => 50 }
#     validates   :email,     :presence   => true,
#                 :format                 => { :with => email_regex },
#                 :uniqueness             => { :case_sensitive => false }

#     validates   :password,  :presence   => true, on: :create,
#                 :confirmation           => true,
#                 :length                 => { :within => 6..40 }

#     before_save :encrypt_password

#     def has_password?(submitted_password)
#         encrypted_password == encrypt(submitted_password)
#     end

#     #method of class, was the email and password valid?
#     def self.authenticate(email, submitted_password)
#         user = find_by_email(email)

#         return nil if user.nil?
#         return user if user.has_password?(submitted_password)
#     end
    
#     private
#         def encrypt_password
#             #salting time....maybe some pepper?
#             self.salt = Digest::SHA2.hexdigest("#{Time.now.utc}--#{password}") if self.new_record?
            
#             #encrypt me some yummy password and store that info
#             self.encrypted_password = encrypt(password)
#         end
    
#         #encrypt password with salt and enjoy.
#         def encrypt(pass)
#             Digest::SHA2.hexdigest("#{self.salt}--#{pass}")
#         end
    
    has_attached_file :avatar, :styles => { :medium=> "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
    validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
    
end
