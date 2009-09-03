require File.dirname(__FILE__) + '/../spec_helper'

describe Post do
  dataset :posts
  dataset :forum_readers
  
  before do
    @site = Page.current_site = sites(:test) if defined? Site
    @reader = Reader.current = readers(:normal)
  end
  
  describe "on creation" do
  
    it "should require a topic" do
      post = Post.new(:body => 'hullabaloo')
      post.should_not be_valid
    end
    
    it "should require body text" do
      post = topics(:older).posts.build(:body => nil)
      post.should_not be_valid
    end

    it "should get a reader automatically" do
      post = topics(:older).posts.build(:body => 'authorless')
      post.should be_valid
      post.reader.should == @reader
    end
    
    it "should update topic reply data" do
      post = topics(:older).posts.create!(:body => 'hullabaloo')
      topic = Topic.find(topic_id(:older))
      topic.last_post.should == post
      topic.replied_by.should == @reader
      topic.replied_at.should be_close(Time.now, 5.seconds)
    end
  end

  describe "during the editable period" do
    before do
      Radiant::Config['forum.editable_period'] = 15
      @post = topics(:older).posts.create!(:body => 'foo')
    end

    it "should be editable by its author" do 
      @post.editable_by?(@post.reader).should be_true
    end

    it "should not be editable by anyone else" do 
      @post.editable_by?(readers(:idle)).should be_false
    end
  end
  
  describe "after the editable period" do
    before do
      Radiant::Config['forum.editable_period'] = 15
      @post = topics(:older).posts.create!(:body => 'foo')
      @post.created_at = Time.now - 16.minutes
    end
    
    it "should no longer be editable by its author" do 
      @post.editable_by?(@post.reader).should be_false
    end
  end

  describe "on removal" do
    it "should revert topic reply data" do
      topicbefore = topics(:older)
      last = topicbefore.last_post
      post = topicbefore.posts.create!(:body => 'uh oh')

      post.destroy
      topicafter = Topic.find(topic_id(:older))
      topicafter.last_post.should == last
      topicafter.replied_by.should == last.reader
      topicafter.replied_at.should == last.created_at
    end
  end
  
  it "should report on which page of its topic it can be found" do
    Radiant::Config['forum.posts_per_page'] = 25
    firstpost = topics(:older).posts.create!(:body => 'foo')
    55.times do |i| 
      topics(:older).posts.create!(:body => 'rhubarb') 
    end
    lastpost = topics(:older).posts.create!(:body => 'bar')
    firstpost.topic_page.should == 1
    lastpost.topic_page.should == 3
  end

end
