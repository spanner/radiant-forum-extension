class PostsDataset < Dataset::Base
  uses :topics, :forum_readers
  
  def load
    create_post "First", :topic_id => topic_id(:older), :reader_id => reader_id(:normal), :body => 'first reply to public topic'
    create_post "Second", :topic_id => topic_id(:older), :reader_id => reader_id(:normal), :body => 'second reply to public topic'
    create_post "Third", :topic_id => topic_id(:private), :reader_id => reader_id(:normal), :body => 'first reply to private topic'
  end
  
  helpers do
    def create_post(name, attributes={})
      create_record :post, name.symbolize
    end
  end
 
end