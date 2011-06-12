require File.dirname(__FILE__) + '/../spec_helper'

describe Forum do
  dataset :forums
  let(:forum) {forums(:public)}
  let(:group_forum) {forums(:grouped)}
  let(:reader) {readers(:normal)}
  let(:unrestricted) {[forums(:public), forums(:other), forums(:misc)]}
  
  it "should require a name" do
    forum.name = nil
    forum.should_not be_valid
    forum.errors.on(:name).should_not be_empty
  end
  
  describe "topics.bydate" do
    it "should list its topics in descending date order" do
      forum.topics.bydate.first.should == topics(:newer)
    end
  end
  
  describe "topics.stickyfirst" do
    it "should list its topics with the sticky first" do
      forum.topics.stickyfirst.first.should == topics(:sticky)
    end
  end
  
  describe "when the forum is public" do
    before do
      Radiant::Config['forum.public?'] = true
    end

    it "should be visible to a reader" do
      forum.visible_to?(reader).should be_true
    end
    
    it "should be visible when there is no reader" do
      forum.visible_to?(nil).should be_true
    end
  end

  describe "when the whole forum is private" do
    before do
      Radiant::Config['forum.public?'] = false
    end

    it "should be visible to a reader" do
      forum.visible_to?(reader).should be_true
    end
    
    it "should not be visible when there is no reader" do
      forum.visible_to?(nil).should be_false
    end
  end

  it "should have a groups association" do
    Forum.reflect_on_association(:groups).should_not be_nil
  end
  
  describe "when a reader is not grouped" do
    it "should list only the ungrouped forums" do
      Forum.visible.should =~ unrestricted
      Forum.visible_to(readers(:ungrouped)).should =~ unrestricted
    end
  end
  
  describe "to a grouped reader" do
    it "should list also the forums of that group" do
      Forum.visible_to(readers(:another)).should =~ unrestricted + [group_forum]
    end
  end

  describe "with a group" do
    it "should report itself visible to a reader who is a group member" do
      group_forum.visible_to?(readers(:another)).should be_true
    end
    it "should report itself invisible to a reader who is not a group member" do
      group_forum.visible_to?(readers(:normal)).should be_false
    end
  end

  describe "without a group" do
    it "should report itself visible to everyone" do
      forum.visible_to?(readers(:normal)).should be_true
      forum.visible_to?(readers(:another)).should be_true
    end
  end

end
