class PostAttachments < ActiveRecord::Migration
  def self.up
    create_table "post_attachments" do |t|
      t.column :post_id, :integer
      t.column :reader_id, :integer
      t.column :position, :integer
      t.column :file_file_name, :string
      t.column :file_content_type, :string
      t.column :file_file_size, :integer
      t.column :file_updated_at, :datetime
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :post_attachments
  end
end
