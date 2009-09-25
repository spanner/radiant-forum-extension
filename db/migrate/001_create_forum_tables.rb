class CreateForumTables < ActiveRecord::Migration
  def self.up

    create_table "forums", :force => true do |t|
      t.column "name",             :string
      t.column "description",      :text
      t.column "site_id",          :integer
      t.column "topics_count",     :integer, :default => 0
      t.column "posts_count",      :integer, :default => 0
      t.column "position",         :integer
      t.column "lock_version",     :integer, :default => 0
      t.column "created_at",       :datetime
      t.column "updated_at",       :datetime
      t.column "created_by_id",    :integer
      t.column "updated_by_id",    :integer
      t.column "reader_id",        :integer
      t.column "for_comments",     :boolean
    end
    add_index "forums", ["site_id"], :name => "index_forums_on_site_id"

    create_table "posts", :force => true do |t|
      t.column "reader_id",        :integer
      t.column "topic_id",         :integer
      t.column "forum_id",         :integer
      t.column "site_id",          :integer
      t.column "body",             :text
      t.column "created_at",       :datetime
      t.column "updated_at",       :datetime
    end
    add_index "posts", ["site_id"], :name => "index_posts_on_site_id"
    add_index "posts", ["forum_id", "created_at"], :name => "index_posts_on_forum_id"
    add_index "posts", ["reader_id", "created_at"], :name => "index_posts_on_reader_id"
    
    create_table "topics",         :force => true do |t|
      t.column "forum_id",         :integer
      t.column "site_id",          :integer
      t.column "reader_id",        :integer
      t.column "name",             :string
      t.column "created_at",       :datetime
      t.column "updated_at",       :datetime
      t.column "replied_at",       :datetime
      t.column "hits",             :integer,  :default => 0
      t.column "sticky",           :boolean,  :default => false
      t.column "posts_count",      :integer,  :default => 0
      t.column "first_post_id",     :integer
      t.column "last_post_id",     :integer
      t.column "locked",           :boolean,  :default => false
      t.column "replied_by_id",    :integer
    end
    add_index "topics", ["site_id"], :name => "index_topics_on_site_id"
    add_index "topics", ["forum_id"], :name => "index_topics_on_forum_id"
    add_index "topics", ["forum_id", "sticky", "replied_at"], :name => "index_topics_on_sticky_and_replied_at"
    add_index "topics", ["forum_id", "replied_at"], :name => "index_topics_on_forum_id_and_replied_at"
    
    add_column :readers, :posts_count, :integer, :default => 0
  end

  def self.down
    drop_table :forums
    drop_table :posts
    drop_table :topics
    remove_column :readers, :posts_count
  end
end
