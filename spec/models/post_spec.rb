require File.dirname(__FILE__) + '/../spec_helper'

describe Post do
  dataset :forums
  
  before do
    @site = Page.current_site = sites(:test) if Page.respond_to? :current_site
  end
  
  describe "on creation" do
    it "should require body text" do
      post = topics(:older).posts.build(:body => nil, :reader => readers(:normal))
      post.should_not be_valid
      post.errors.on(:body).should_not be_nil
    end

    it "should require a reader" do
      post = topics(:older).posts.build(:body => 'authorless')
      post.should_not be_valid
      post.errors.on(:reader).should_not be_nil
    end
    
    describe "when added to a topic" do
      before do
        Rails.logger.warn ">>"
        @post = topics(:older).posts.create!(:body => 'and its my post about new marmalade', :reader => readers(:normal))
      end
      
      it "should update its indexable form" do
        @post.search_text.should == "older post new marmalade"
      end

      it "should update topic reply data" do
        topic = Topic.find(topic_id(:older))
        topic.replied_by.should == readers(:normal)
        topic.replied_at.should be_close(Time.now, 10.seconds)
      end
    end
  end

  describe "during the editable period" do
    before do
      Radiant::Config['forum.editable_period'] = 15
      @post = topics(:older).posts.create!(:body => 'foo', :reader => readers(:normal))
    end

    it "should be editable by its author" do 
      @post.editable_by?(readers(:normal)).should be_true
    end

    it "should not be editable by anyone else" do 
      @post.editable_by?(readers(:another)).should be_false
    end
  end
  
  describe "after the editable period" do
    before do
      Radiant::Config['forum.editable_period'] = 15
      @post = topics(:older).posts.create!(:body => 'foo', :reader => readers(:normal), :created_at => Time.now - 16.minutes)
    end
    
    it "should not be editable by its author" do 
      @post.editable_by?(@post.reader).should be_false
    end

    it "should not be editable by anyone else" do 
      @post.editable_by?(readers(:another)).should be_false
    end
  end

  describe "on removal" do
    before do
      @last = topics(:older).posts.last
      @post = topics(:older).posts.create!(:body => 'uh oh', :reader => readers(:normal))
    end
    it "should revert topic reply data" do
      @post.destroy
      topic = Topic.find(topic_id(:older))
      topic.replied_by.should == @last.reader
      topic.replied_at.should be_close(@last.created_at, 1.second)
    end
  end
  
  it "should report on which page of its topic it can be found" do
    Radiant::Config['forum.paginate_posts?'] = true
    Radiant::Config['forum.posts_per_page'] = 25
    firstpost = topics(:older).posts.create!(:body => 'foo', :reader => readers(:normal))
    55.times do |i| 
      topics(:older).posts.create!(:body => 'rhubarb', :reader => readers(:normal))
    end
    lastpost = topics(:older).posts.create!(:body => 'bar', :reader => readers(:normal))
    firstpost.page_when_paginated.should == 1
    lastpost.page_when_paginated.should == 3
  end

end
