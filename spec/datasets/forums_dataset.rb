class ForumsDataset < Dataset::Base
  uses :forum_readers, :home_page, :users
  
  def load  
    create_layout "Forum"

    create_forum "Public" do
      create_topic "older", :reader => readers(:normal), :replied_at => 2.days.ago do
        add_post "First", :created_at => 2.days.ago, :body => 'original topic message'
        add_post "Second", :created_at => 1.day.ago, :body => 'first reply to public topic'
      end
      create_topic "newer", :reader => readers(:normal), :replied_at => 1.day.ago
    end
      
    create_forum "Private" do
      create_topic "sticky", :reader => readers(:normal), :replied_at => 3.days.ago, :sticky => true
      create_topic "locked", :reader => readers(:normal), :locked => true, :replied_at => 1.year.ago
      create_topic "private", :reader => readers(:normal), :replied_at => 1.day.ago do
        add_post "Third", :created_at => 4.hours.ago, :body => 'Reply to private topic'
      end
    end
    
    create_forum "Misc" do
      create_topic "empty", :reader => readers(:notable)
    end
    
    create_page "Commentable", :commentable => true, :comments_closed => false, :created_by => users(:admin) do
      add_post "Comment", :created_at => 2.days.ago, :body => 'first comment on page'
      add_post "Recomment", :created_at => 1.day.ago, :body => 'second comment on page'
    end

    create_page "Uncommented", :commentable => true, :comments_closed => false, :created_by => users(:admin)
    create_page "Uncommentable", :commentable => false, :comments_closed => false, :created_by => users(:admin)
    create_page "Comments closed", :commentable => true, :comments_closed => true, :created_by => users(:admin)
  end
  
  helpers do
    def create_layout(name, attributes={})
      create_model :layout, name.symbolize, attributes.update(:name => name)
    end

    def create_forum(name, attributes={})
      attributes = forum_attributes(attributes.update(:name => name))
      symbol = name.symbolize
      create_model :forum, symbol, attributes
      if block_given?
        @forum_id = forum_id(symbol)
        yield
        @forum_id = nil
      end
    end
    
    def create_topic(name, attributes={})
      attributes = topic_attributes(attributes.update(:name => name))
      symbol = name.symbolize
      reader = attributes.delete(:reader)
      create_model :topic, symbol, attributes
      @topic_id = topic_id(symbol)
      add_post("#{name}_first_post", :reader => reader)
      yield if block_given?
      @topic_id = nil
    end
  
    def add_post(name, attributes={})
      attributes = post_attributes(attributes)
      symbol = name.symbolize
      create_model :post, symbol, attributes
      if block_given?
        @post_id = post_id(symbol)
        yield
        @post_id = nil
      end
    end
 
    def forum_attributes(attributes={})
      name = attributes[:name] || "Forum"
      symbol = name.symbolize
      attributes = { 
        :name => name,
        :created_at => Time.now
      }.merge(attributes)
      attributes[:site_id] = site_id(:test) if Forum.reflect_on_association(:site)
      attributes
    end

    def topic_attributes(attributes={})
      name = attributes[:name] || "A topic"
      att = {
        :name => name,
        :forum_id => @forum_id
      }.merge(attributes)
      attributes[:site_id] ||= site_id(:test) if Topic.reflect_on_association(:site)
      att
    end
  
    def post_attributes(attributes={})
      att = {
        :body => "Message body",
        :reader => readers(:normal),
        :created_at => 1.day.ago,
        :topic_id => @topic_id,
        :page_id => @current_page_id
      }.merge(attributes)
      att[:site_id] ||= site_id(:test) if Post.reflect_on_association(:site)
      att
    end
  end
  
end