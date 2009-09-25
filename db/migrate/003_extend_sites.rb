class ExtendSites < ActiveRecord::Migration
  def self.up
    if defined? Site
      add_column :sites, :forum_layout_id, :integer
    end
  end

  def self.down
    if defined? Site
      remove_column :sites, :forum_layout_id
    end
  end
end
