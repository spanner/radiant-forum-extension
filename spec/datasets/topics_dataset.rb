class TopicsDataset < Dataset::Base
  uses :forum_readers, :forum_pages, :forums
  
  def load  
    create_topic "older", :reader => readers(:normal), :forum => forums(:public), :body => 'this goes in the first post really', :created_at => 4.days.ago, :replied_at => 2.days.ago
    create_topic "newer", :reader => readers(:normal), :forum => forums(:public), :body => 'this goes in the first post really', :created_at => 2.days.ago, :replied_at => 1.day.ago
    create_topic "sticky", :reader => readers(:normal), :forum => forums(:private), :body => 'this goes in the first post really', :created_at => 2.days.ago, :replied_at => 3.days.ago, :sticky => true
    create_topic "locked", :reader => readers(:normal), :forum => forums(:public), :body => 'this goes in the first post really', :locked => true, :replied_at => 1.year.ago
    create_topic "private", :reader => readers(:normal), :forum => forums(:private), :body => 'this goes in the first post really', :created_at => 2.days.ago, :replied_at => 1.day.ago
    create_topic "minimal", :reader => readers(:normal), :forum => forums(:misc), :body => 'this goes in the first post really'
    create_topic "comments", :reader => readers(:normal), :forum => forums(:comments), :body => 'this goes in the first post really', :locked => false, :page => pages(:commentable)
  end
  
  helpers do
    def create_topic(name, attributes={})
      attributes = topic_attributes(attributes.update(:name => name))
      create_model :topic, name.symbolize, attributes
    end
  end
 
  def topic_attributes(attributes={})
    name = attributes[:name] || "A topic"
    att = {
      :name => name,
      :reader => readers(:normal),
      :created_at => Time.now
    }.merge(attributes)
    attributes[:site_id] ||= site_id(:test) if Reader.reflect_on_association(:site)
    att
  end
 
 
 
 
 
 
end