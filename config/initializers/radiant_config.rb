Radiant.config do |config|
  config.namespace('forum') do |forum|
    forum.define 'allow_registration?', :default => true
    forum.define 'public?', :default => true
    forum.define 'editable_period', :type => :integer, :default => 15, :units => "minutes"
    forum.define 'allow_page_comments?', :default => true
    forum.define 'allow_attachments?', :default => true
    forum.define 'attachment.content_types'
    forum.define 'attachment.max_size', :type => :integer, :default => 10, :units => "MB"
    forum.define 'layout', :select_from => lambda { Layout.all.map(&:name) }, :allow_blank => false
  end
end 
