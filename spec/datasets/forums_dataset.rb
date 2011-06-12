class ForumsDataset < Dataset::Base
  uses :readers
  
  def load  
    create_layout "Forum"

    create_forum "Public" do
      create_topic "sticky", :reader => readers(:normal), :replied_at => 3.days.ago, :sticky => true
      create_topic "older", :reader => readers(:normal), :replied_at => 2.days.ago do
        create_post "First", :created_at => 2.days.ago, :body => 'original topic message'
        create_post "Second", :created_at => 1.day.ago, :body => 'first reply to public topic'
      end
      create_topic "newer", :reader => readers(:normal), :replied_at => 1.day.ago
    end
      
    create_forum "Other" do
      create_topic "locked", :reader => readers(:normal), :locked => true, :replied_at => 1.year.ago
      create_topic "another", :reader => readers(:normal), :replied_at => 1.day.ago do
        create_post "Third", :created_at => 4.hours.ago, :body => 'Reply to another topic'
      end
    end
    
    create_forum "Misc" do
      create_topic "empty", :reader => readers(:another)
      create_topic "busy", :reader => readers(:another) do
        60.times do |i|
          create_post "test_#{i}", :body => "test #{i}", :reader => readers(:normal), :created_at => (100-i).minutes.ago
        end
        create_post "nearly", :body => "test by visible", :reader => readers(:visible)
        create_post "finally", :body => "test by another", :reader => readers(:another)
      end
    end
    
    create_forum "Grouped" do
      create_topic "grouped", :reader => readers(:another)
    end
    
    create_page "Commentable", :commentable => true, :comments_closed => false, :created_by => users(:admin) do
      create_post "Comment", :created_at => 2.days.ago, :body => 'first comment on page'
      create_post "Recomment", :created_at => 1.day.ago, :body => 'second comment on page'
    end

    create_page "Uncommented", :commentable => true, :comments_closed => false, :created_by => users(:admin)
    create_page "Uncommentable", :commentable => false, :comments_closed => false, :created_by => users(:admin)
    create_page "Comments closed", :commentable => true, :comments_closed => true, :created_by => users(:admin)

    
    restrict_to_group :special, [forums(:grouped)]
  end
  
  helpers do
    def create_forum(name, attributes={})
      symbol = name.symbolize
      create_model :forum, symbol, default_forum_attributes(name).merge(attributes)
      if block_given?
        @forum_id = forum_id(symbol)
        yield
        @forum_id = nil
      end
    end
    
    def create_topic(name, attributes={})
      symbol = name.symbolize
      reader = attributes.delete(:reader)
      create_model :topic, symbol, default_topic_attributes(name).merge(attributes)
      @topic_id = topic_id(symbol)
      create_post("#{name}_first_post", :reader => reader)
      yield if block_given?
      @topic_id = nil
    end
  
    def create_post(name, attributes={})
      symbol = name.symbolize
      create_model :post, name.symbolize, default_post_attributes.merge(attributes)
      if block_given?
        @post_id = post_id(symbol)
        yield
        @post_id = nil
      end
    end
 
    def default_forum_attributes(name="Forum")
      { 
        :name => name,
        :created_at => Time.now
      }
    end

    def default_topic_attributes(name="A topic")
      {
        :name => name,
        :forum_id => @forum_id
      }
    end
  
    def default_post_attributes
      {
        :body => "Message body",
        :reader => readers(:normal),
        :created_at => 1.day.ago,
        :topic_id => @topic_id,
        :page_id => @current_page_id
      }
    end
  end
  
end