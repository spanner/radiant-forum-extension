require File.dirname(__FILE__) + "/../spec_helper"

describe 'Forum-extended page' do
  dataset :posts
  dataset :forum_pages
  
  before do
    login_as_reader(:normal)
  end

  it "should have a topic association" do
    Page.reflect_on_association(:topic).should_not be_nil
  end
 
  it "should create a new topic if it doesn't already have one" do
    topic = pages(:ordinary).find_or_build_topic
    topic.new_record?.should be_true
  end

  it "should not create a topic if it does already have one" do
    topic = pages(:commentable).find_or_build_topic
    topic.new_record?.should be_false
    topic.should == topics(:comments)
  end

  it "should not create a topic if it isn't commentable" do
    topic = pages(:uncommentable).find_or_build_topic
    topic.should be_nil
  end

  it "should know whether it has posts or not" do
    page = pages(:ordinary)
    topic = page.find_or_build_topic
    topic.name = "Foo"
    topic.body = "Bar"
    topic.save
    page.has_posts?.should be_false
    topic.posts.create(:body => 'foo')
    pages(:ordinary).has_posts?.should be_true
  end
  
  it "should normally be commentable" do
    pages(:ordinary).locked?.should be_false
  end
  
  it "should be locked if marked not commentable" do
    pages(:uncommentable).locked?.should be_true
  end
  
  it "should be locked if marked comments_closed" do
    pages(:comments_closed).locked?.should be_true
  end
  
  it "should be locked if there is a commentable period and it has expired" do
    Radiant::Config['forum.commentable_period'] = 28
    page = pages(:commentable)
    page.commentable_period.should == 28.days
    page.locked?.should be_false
    page.created_at = Time.now - 30.days
    page.locked?.should be_true
  end
    
end
