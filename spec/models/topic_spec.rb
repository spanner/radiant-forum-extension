require File.dirname(__FILE__) + '/../spec_helper'

describe Topic do
  dataset :topics

  before do
    @site = Page.current_site = sites(:test)
    @reader = Reader.current_reader = readers(:normal)
  end
  
  describe "on creation" do
    before do
      @topic = Topic.create!(:name => 'testing', :forum => forums(:public))
    end
    
    it "should set default values" do
      @topic.sticky.should be_false
      @topic.replied_at.should be_close(Time.now, 5.seconds)
    end

    [:name, :forum].each do |field|
      it "should require a #{field}" do
        @topic.send("#{field}=".intern, nil)
        @topic.should_not be_valid
        @topic.errors.on(field).should_not be_empty
      end
    end
    
    it "should get a reader automatically" do
      topic = forums(:public).topics.build(:name => 'testing again')
      topic.should be_valid
      topic.reader.should == @reader
    end
    
  end
  
  describe "with posts" do
    dataset :posts

    before do
      @topic = topics(:older)
    end

    it "should know on which page to find a given post" do
      
    end

    it "should know who last replied to it" do
      
    end
  end
  

  it "should revise counter caches when it moves to another forum" do
    
  end
end
