class Order < ActiveRecord::Base
    has_many :docs, :dependent => :destroy
    has_many :line_items
    has_many :items
#    belongs_to :customer, foreign_key: "listid"
    belongs_to :customer
    accepts_nested_attributes_for :line_items, :reject_if => :reject_blank_items
    
#    this is used for the paperclip gem, in order to upload pdfs
    has_attached_file :docs, :url => "/:class/:attachment/:id/:basename.:extension", :path => ":rails_root/public/:class/:attachment/:id/:basename.:extension"
#        :url => "/documents/:id/download"
#    
#    validates_attachment_content_type :file, :content_type => 'text/plain'
    validates_attachment_content_type :docs, :content_type => "application/pdf"
    before_post_process :docs
    
    #add more of this crazy model, like validation's and such. You know you want to.
    
    #This is to eliminate extra entries on Orders
    def reject_blank_items(attributes)
      attributes[:product_id].blank? &&
      attributes[:qty].blank?
    end
    
    
#    This was a test from SO, no succes so far
#    before_save :destroy_doc?
#    
#    def doc_delete
#        @doc_delete ||= "0"
#    end
#    
#    def doc_delete=(value)
#        @doc_delete = value
#    end
#    
#private
#    def destroy_doc?
#        self.doc.clear if @doc_delete == "1"
#    end
#    
end

