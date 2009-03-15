class ExtendSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :forum_layout_id, :integer
  end

  def self.down
    remove_column :sites, :forum_layout_id
  end
end
