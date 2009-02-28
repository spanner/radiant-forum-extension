class TopicsDataset < Dataset::Base
  uses :forum_readers, :forum_pages, :forums
  
  def load
    Page.current_site = sites(:test)
    Reader.current_reader = readers(:normal)
    
    create_topic "older", :reader => readers(:normal), :forum => forums(:public), :body => 'this goes in the first post really', :created_at => 4.days.ago, :replied_at => 2.days.ago
    create_topic "newer", :reader => readers(:normal), :forum => forums(:public), :body => 'this goes in the first post really', :created_at => 2.days.ago, :replied_at => 1.day.ago
    create_topic "sticky", :reader => readers(:normal), :forum => forums(:private), :body => 'this goes in the first post really', :created_at => 2.days.ago, :replied_at => 3.days.ago, :sticky => true
    create_topic "private", :reader => readers(:normal), :forum => forums(:private), :body => 'this goes in the first post really', :created_at => 2.days.ago, :replied_at => 1.day.ago
    create_topic "minimal", :reader => readers(:normal), :forum => forums(:misc), :body => 'this goes in the first post really'
    create_topic "locked", :reader => readers(:normal), :forum => forums(:public), :body => 'this goes in the first post really', :locked => true, :replied_at => 1.year.ago
    create_topic "comments", :reader => readers(:normal), :forum => forums(:comments), :body => 'this goes in the first post really', :locked => true, :page => pages(:commentable)

    Page.current_site = sites(:elsewhere)
    create_topic "elsewhere", :reader => readers(:elsewhere), :forum => forums(:elsewhere), :body => 'this goes in the first post really', :locked => true, :replied_at => 1.year.ago
  end
  
  helpers do
    def create_topic(name, attributes={})
      create_model :topic, name.symbolize, attributes.update(:name => name)
    end
  end
 
end