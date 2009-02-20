require File.dirname(__FILE__) + '/../spec_helper'

describe Forum do
  dataset :topics
  
  before do
    @site = Page.current_site = sites(:test)
    @forum = forums(:public)
    @reader = Reader.current_reader = readers(:normal)
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
    @forum = forums(:private)
    @forum.topics.first.should == topics(:sticky)
  end

  describe ".find_or_create_comments_forum" do
    
    it "should create a comments forum if there is none" do
      Forum.should_receive(:find_by_for_comments)
      @forum = Forum.find_or_create_comments_forum
      @forum.for_comments.should be_true
      @forum.name.should == 'Page Comments'
      @forum.created_at.should be_close(Time.now, 5.seconds)
    end
    
    it "should return the existing comments forum if there is one" do
      comments_forum = forums(:misc)
      comments_forum.for_comments = true
      comments_forum.save!
      @forum = Forum.find_or_create_comments_forum
      @forum.should == comments_forum
    end
  end
end
