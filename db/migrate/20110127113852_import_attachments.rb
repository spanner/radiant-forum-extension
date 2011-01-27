class ImportAttachments < ActiveRecord::Migration
  def self.up
    add_column :post_attachments, :old_id, :integer
  end

  def self.down
    remove_column :post_attachments, :old_id
  end
end
