require File.dirname(__FILE__) + '/../spec_helper'

describe Post do
  dataset :posts
  dataset :topics
  dataset :forum_readers
  
  describe "on creation" do
    
    [:body, :topic, :reader].each do |field|
      it "should require a #{field}" do
        @post = Post.new(:body => 'hullabaloo')
        @post.topic = topics(:older)
        @post.reader = readers(:normal)
        @post.send("#{field}=".intern, nil)
        @post.should_not be_valid
        @post.errors.on(field).should_not be_empty
      end
    end

    it "should update topic reply data" do
      @topic = Topic.new(:name => 'testing')
      @topic.forum = forums(:public)
      @topic.reader = readers(:industrious)
      @topic.replied_at = 1.week.ago
      @topic.save!
      @post = Post.new(:body => 'hullabaloo')
      @post.topic = @topic
      @post.reader = readers(:normal)
      @post.save!
      @topic.reload
      @topic.replied_by_reader.should == readers(:normal)
      @topic.replied_at.should be_close(Time.now, 5.seconds)
    end
  end

  describe "on removal" do
    it "should update topic reply data" do
      
    end
  end
  
  it "should allow editing by its author" do
  end

  it "should refuse editing by readers other than its author" do
  end

  it "should know on what page of its topic it can be found" do
  end

end
