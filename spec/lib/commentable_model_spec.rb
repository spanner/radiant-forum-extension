require File.dirname(__FILE__) + "/../spec_helper"

describe 'Post-holder' do
  dataset :forums
  
  before do
    Radiant::Config['forum.paginate_posts?'] = true
    @topic = topics(:empty)
  end

  describe "without replies" do
    it "should announce posts but not replies" do
      @topic.posts.count.should == 1
      @topic.has_posts?.should be_true
      @topic.has_replies?.should be_false
    end
  end
  
  describe "with replies" do
    before do
      60.times do |i|
        @topic.posts.create!(:body => "test #{i}", :reader => readers(:normal), :created_at => (100-i).minutes.ago)
      end
      @topic.posts.create!(:body => "test by another", :reader => readers(:idle))
      @topic.reload
    end
    
    it "should have many posts" do
      @topic.posts.count.should == 62
    end

    it "should report the number of replies to the original post" do
      @topic.reply_count.should == 61
      @topic.replies.length.should == @topic.reply_count
    end

    it "should report the number of readers taking part" do
      calculated = @topic.posts.map(&:reader).uniq
      Rails.logger.warn ">>"
      @topic.voice_count.should == calculated.length
      Rails.logger.warn "<<"
    end

    it "should report the number of readers replying" do
      calculated = @topic.posts.map(&:reader).uniq - [@topic.posts.first.reader]
      @topic.other_voice_count.should == calculated.length
    end

    it "should report the list of readers taking part" do
      @topic.voices.length.should == 3
      @topic.voices.include?(readers(:notable)).should be_true
      @topic.voices.include?(readers(:normal)).should be_true
      @topic.voices.include?(readers(:idle)).should be_true
    end

    it "should report the list of readers replying" do
      @topic.other_voices.length.should == 2
      @topic.other_voices.include?(readers(:notable)).should be_false
      @topic.other_voices.include?(readers(:normal)).should be_true
      @topic.other_voices.include?(readers(:idle)).should be_true
    end

    it "should paginate its posts" do
      @topic.paged?.should be_true
    end

    it "should know on which page to find a given post" do
      @topic.page_for(Post.find_by_body("test 16")).should == 1
      @topic.page_for(Post.find_by_body("test 36")).should == 2
      @topic.page_for(Post.find_by_body("test 56")).should == 3
    end

    it "should read config to find the number of posts per page" do
      Radiant::Config['forum.posts_per_page'] = 15
      @topic.page_for(Post.find_by_body("test 16")).should == 2
      @topic.page_for(Post.find_by_body("test 36")).should == 3
      @topic.page_for(Post.find_by_body("test 56")).should == 4
    end

    it "should know when it was last replied to" do
      @topic.replied_at.should == @topic.posts.last.created_at
    end

    it "should know by whom it was last replied to" do
      @topic.replied_by.should == readers(:idle)
    end
  end
end
