class SearchText < ActiveRecord::Migration
  def self.up
    add_column :posts, :search_text, :text
  end

  def self.down
    remove_column :posts, :search_text
  end
end
