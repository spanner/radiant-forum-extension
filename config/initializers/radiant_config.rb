Radiant.config do |config|
  config.namespace('forum') do |forum|
    forum.define 'allow_registration?', :default => true
    forum.define 'public?', :default => true
    forum.define 'toolbar?', :default => true
    forum.define 'editable_period', :type => :integer, :default => 15, :units => "minutes"
    forum.define 'allow_page_comments?', :default => true
    forum.define 'allow_attachments?', :default => true
    forum.define 'attachment.content_types'
    forum.define 'attachment.max_size', :type => :integer, :default => 10, :units => "MB"
    forum.define 'layout', :select_from => lambda { Layout.all.map(&:name) }, :allow_blank => false
    forum.define 'default_forum', :select_from => lambda { Forum.all.map(&:name) }, :allow_blank => false
    forum.define 'paginate_posts?', :default => true
    forum.define 'posts_per_page', :type => :integer, :default => 20
    forum.define 'commentable_period', :type => :integer, :default => 7, :units => "days"
  end
end 
