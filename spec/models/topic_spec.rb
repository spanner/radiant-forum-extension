require File.dirname(__FILE__) + '/../spec_helper'

describe Topic do
  dataset :forums

  describe "on creation" do
    let(:topic) {
      Post.create!(
        :body => "first post body", 
        :reader_id => reader_id(:normal),
        :topic_attributes => {
          :name => 'testing',
          :forum_id => forum_id(:public)
        }
      ).topic
      
    }    
    it "should set default values" do
      topic.sticky?.should be_false
      topic.locked?.should be_false
      topic.replied_by.should == readers(:normal)
      topic.replied_at.should be_close(Time.now, 1.minute)
    end

    [:name].each do |field|
      it "should require a #{field}" do
        topic.send("#{field}=".intern, nil)
        topic.should_not be_valid
        topic.errors.on(field).should_not be_empty
      end
    end
    
    describe "when the whole forum is public" do
      before do
        Radiant::Config['forum.public?'] = true
      end

      it "should be visible to a reader" do
        topic.visible_to?(@reader).should be_true
      end

      it "should be visible when there is no reader" do
        topic.visible_to?(nil).should be_true
      end
    end

    describe "when the whole forum is private" do
      before do
        Radiant::Config['forum.public?'] = false
      end

      it "should be visible to a reader" do
        topic.visible_to?(readers(:normal)).should be_true
      end

      it "should not be visible when there is no reader" do
        topic.visible_to?(nil).should be_false
      end
    end
    
    describe "in a grouped forum" do
      it "should be visible to a group member" do
        topics(:grouped).visible_to?(readers(:another)).should be_true
      end

      it "should not be visible to a non group member" do
        topics(:grouped).visible_to?(readers(:normal)).should be_false
      end
    end
  end
  
end
