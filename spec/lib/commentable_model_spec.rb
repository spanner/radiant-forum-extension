require File.dirname(__FILE__) + "/../spec_helper"

# NB post-holder may be Page or Topic (or whatever else has been made commentable)

describe 'Post-holder' do
  dataset :forums
  
  before do
    Radiant::Config['forum.paginate_posts?'] = true
  end
  
  let(:topic) { topics(:empty) }
  let(:busy_topic) { topics(:busy) }

  describe "without replies" do
    it "should announce posts but not replies" do
      topic.posts.count.should == 1
      topic.has_posts?.should be_true
      topic.has_replies?.should be_false
    end
  end
  
  describe "with replies" do
    it "should have many posts" do
      busy_topic.posts.count.should == 63
    end

    it "should report the number of replies to the original post" do
      busy_topic.reply_count.should == 62
      busy_topic.replies.length.should == busy_topic.reply_count
    end

    it "should report the number of readers taking part" do
      calculated = busy_topic.posts.map(&:reader).uniq
      busy_topic.voice_count.should == calculated.length
    end

    it "should report the number of readers replying" do
      calculated = busy_topic.posts.map(&:reader).uniq - [topic.posts.first.reader]
      busy_topic.other_voice_count.should == calculated.length
    end

    it "should report the list of readers taking part" do
      busy_topic.voices.should =~ [readers(:normal), readers(:another), readers(:visible)]
    end

    it "should report the list of readers replying" do
      busy_topic.other_voices.should =~ [readers(:visible), readers(:normal)]
    end

    it "should paginate its posts" do
      busy_topic.paged?.should be_true
    end

    it "should know on which page to find a given post" do
      busy_topic.page_for(Post.find_by_body("test 16")).should == 1
      busy_topic.page_for(Post.find_by_body("test 36")).should == 2
      busy_topic.page_for(Post.find_by_body("test 56")).should == 3
    end

    it "should read config to find the number of posts per page" do
      Radiant::Config['forum.posts_per_page'] = 15
      busy_topic.page_for(Post.find_by_body("test 16")).should == 2
      busy_topic.page_for(Post.find_by_body("test 36")).should == 3
      busy_topic.page_for(Post.find_by_body("test 56")).should == 4
    end

    it "should know when it was last replied to" do
      busy_topic.replied_at.should == posts(:finally).created_at
    end

    it "should know by whom it was last replied to" do
      busy_topic.replied_by.should == posts(:finally).reader
    end
  end
end
