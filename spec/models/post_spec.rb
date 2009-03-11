require File.dirname(__FILE__) + '/../spec_helper'

describe Post do
  dataset :posts
  dataset :forum_readers
  
  before do
    @site = Page.current_site = sites(:test) if defined? Site
    @reader = Reader.current_reader = readers(:normal)
  end
  
  describe "on creation" do
  
    [:body, :topic].each do |field|
      it "should require a #{field}" do
        post = Post.new(:body => 'hullabaloo')
        post.topic = topics(:older)
        post.send("#{field}=".intern, nil)
        post.should_not be_valid
        post.errors.on(field).should_not be_empty
      end
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
    
  end

end
