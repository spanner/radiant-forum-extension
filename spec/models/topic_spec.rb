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
      60.times do |i|
        @topic.posts.create!(:body => "test #{i}")
      end
      @topic.posts.create!(:body => "test by another", :reader => readers(:idle))
      @topic.reload
    end

    it "should paginate posts" do
      @topic.posts_count.should == 63
      @topic.paged?.should be_true
    end

    it "should know on which page to find a given post" do
      post = Post.find_by_body("test 55")
      @topic.page_for(post).should == 2
    end

    it "should know who last replied to it" do
      @topic.replied_by.should == readers(:idle)
    end

    describe "when moved to another forum" do
      before do
        @oldcount = @topic.forum.posts_count
        newforum = forums(:private)
        @newcount = newforum.posts_count
        @topic.forum = newforum
        @topic.save!
      end

      it "should move its posts too" do
        t = Topic.find(@topic.id)
        t.posts.each do |p|
          p.forum_id.should == forum_id(:private)
        end
      end

      it "should revise counter caches" do
        ff = Forum.find(forum_id(:public))
        tf = Forum.find(forum_id(:private))
        ff.posts_count.should < @oldcount
        tf.posts_count.should > @newcount
      end
    end
  end
end
