Radiant.config do |config|
  config.namespace('forum') do |forum|
    forum.define 'public?', :default => true
    forum.define 'cached?', :default => true
    forum.define 'cache_duration', :default => 60, :type => :integer, :units => "minutes"
    forum.define 'toolbar?', :default => true
    forum.define 'editable_period', :type => :integer, :default => 30, :units => "minutes"
    forum.define 'offer_rss?', :default => false
    forum.define 'allow_page_comments?', :default => true
    forum.define 'allow_attachments?', :default => true
    forum.define 'attachment.content_types'
    forum.define 'attachment.max_size', :type => :integer, :default => 10, :units => "MB"
    forum.define 'layout', :select_from => lambda { Layout.all.map(&:name) }, :allow_blank => false
    forum.define 'default_forum', :select_from => lambda { Forum.all.map(&:name) }, :allow_blank => false
    forum.define 'paginate_posts?', :default => true
    forum.define 'posts_per_page', :type => :integer, :default => 20
    forum.define 'commentable_period', :type => :integer, :default => 7, :units => "days"
    forum.define 'allow_search_by_reader?', :default => true
  end
end 
