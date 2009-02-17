class TopicsDataset < Dataset::Base
  uses :forums, :forum_readers
  
  def load
    create_topic "older", :reader_id => reader_id(:normal), :forum_id => forum_id(:public), :replied_at => 2.days.ago
    create_topic "newer", :reader_id => reader_id(:normal), :forum_id => forum_id(:public), :replied_at => 1.day.ago
    create_topic "sticky", :reader_id => reader_id(:normal), :forum_id => forum_id(:private), :replied_at => 3.days.ago, :sticky => true
    create_topic "private", :reader_id => reader_id(:normal), :forum_id => forum_id(:private), :replied_at => 1.day.ago
    create_topic "minimal", :reader_id => reader_id(:normal), :forum_id => forum_id(:public)
  end
  
  helpers do
    def create_topic(name, attributes={})
      create_record :topic, name.symbolize, attributes.update(:name => name)
    end
  end
 
end