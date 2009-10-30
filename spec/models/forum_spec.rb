require File.dirname(__FILE__) + '/../spec_helper'

describe Forum do
  dataset :topics
  
  before do
    @site = Page.current_site = sites(:test) if defined? Site
    @forum = forums(:public)
    @reader = Reader.current = readers(:normal)
  end
  
  it "should require a name" do
    @forum.name = nil
    @forum.should_not be_valid
    @forum.errors.on(:name).should_not be_empty
  end
  
  it "should list its topics in date order" do
    @forum.topics.first.should == topics(:newer)
  end
  
  it "should list its topics with the sticky first" do
    forums(:private).topics.first.should == topics(:sticky)
  end
  
  it "should report itself visible" do
    forums(:public).visible_to?(@reader).should be_true
    forums(:public).visible_to?(nil).should be_true
  end

  describe ".find_or_create_comments_forum" do
    
    it "should return the existing comments forum when there is one" do
      @forum = Forum.find_or_create_comments_forum
      @forum.should == forums(:comments)
    end

    it "should create a comments forum if there is none" do
      forums(:comments).delete
      Forum.should_receive(:find_by_for_comments)
      @forum = Forum.find_or_create_comments_forum
      @forum.for_comments.should be_true
      @forum.name.should == 'Page Comments'
      @forum.created_at.should be_close(Time.now, 5.seconds)
    end
    
  end
end
