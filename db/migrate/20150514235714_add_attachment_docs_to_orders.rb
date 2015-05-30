class AddAttachmentDocsToOrders < ActiveRecord::Migration
  def self.up
    change_table :orders do |t|
      t.attachment :docs
    end
  end

  def self.down
    remove_attachment :orders, :docs
  end
end
