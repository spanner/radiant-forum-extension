class PageRepliedAt < ActiveRecord::Migration
  def self.up
    add_column :pages, :replied_at, :datetime
    add_column :pages, :replied_by_id, :integer
  end

  def self.down
    remove_column :pages, :replied_at
    remove_column :pages, :replied_by_id
  end
end
