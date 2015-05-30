class Order < ActiveRecord::Base
    
    has_attached_file :docs, :url => "/:class/:attachment/:id/:basename.:extension", :path => ":rails_root/public/:class/:attachment/:id/:basename.:extension"
#        :url => "/documents/:id/download"
#    
#    validates_attachment_content_type :file, :content_type => 'text/plain'
    validates_attachment_content_type :docs, :content_type => "application/pdf"
    before_post_process :docs
    
    #add more of this crazy model, like validation's and such. You know you want to.
    
end
