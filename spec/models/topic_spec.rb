require File.dirname(__FILE__) + '/../spec_helper'

describe Topic do
  dataset :topics

  before do
    @site = Page.current_site = sites(:test) if defined? Site
    @reader = Reader.current = readers(:normal)
  end
  
  describe "on creation" do
    before do
      @topic = Topic.create!(:name => 'testing', :body => 'this is the first post body but validation requires it', :forum => forums(:public))
    end
    
    it "should set default values" do
      @topic.sticky?.should be_false
      @topic.locked?.should be_false
      @topic.replied_by.should be_nil
      @topic.replied_at.should be_close(@topic.created_at, 1.minute)
    end

    [:name, :forum].each do |field|
      it "should require a #{field}" do
        @topic.send("#{field}=".intern, nil)
        @topic.should_not be_valid
        @topic.errors.on(field).should_not be_empty
      end
    end
    
    it "should get a reader automatically" do
      @topic.reader.should == @reader
    end
    
    it "should get a first post automatically" do
      @topic.first_post.should_not be_nil
      @topic.first_post.body.should == 'this is the first post body but validation requires it'
    end

    it "should report itself visible" do
      @topic.visible_to?(@reader).should be_true
      @topic.visible_to?(nil).should be_true
    end

  end
  
  describe "with posts" do
    dataset :posts

    before do
      @topic = topics(:older)
      60.times do |i|
        @topic.posts.create!(:body => "test #{i}", :created_at => (100-i).minutes.ago)
      end
      @topic.posts.create!(:body => "test by another", :reader => readers(:idle))
      @topic.reload
    end

    it "should paginate posts" do
      @topic.posts_count.should == 64
      @topic.paged?.should be_true
    end

    it "should know on which page to find a given post" do
      @topic.page_for(Post.find_by_body("test 15")).should == 1
      @topic.page_for(Post.find_by_body("test 35")).should == 2
      @topic.page_for(Post.find_by_body("test 55")).should == 3
    end

    it "should read config to find the number of posts per page" do
      Radiant::Config['forum.posts_per_page'] = 15
      @topic.page_for(Post.find_by_body("test 15")).should == 2
      @topic.page_for(Post.find_by_body("test 35")).should == 3
      @topic.page_for(Post.find_by_body("test 55")).should == 4
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
