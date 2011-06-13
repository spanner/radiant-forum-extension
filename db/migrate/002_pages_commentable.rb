class PagesCommentable < ActiveRecord::Migration
  def self.up
    add_column :pages, :commentable, :boolean, :default => true
    add_column :pages, :comments_closed, :boolean, :default => false
    add_column :topics, :page_id, :integer
    add_index :topics, :page_id, :name => "index_topics_on_page_id"
  end

  def self.down
    remove_column :pages, :commentable
    remove_column :pages, :comments_closed
    remove_column :topics, :page_id
    remove_index :topics, :page_id
  end
end
