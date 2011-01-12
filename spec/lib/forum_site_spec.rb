require File.dirname(__FILE__) + "/../spec_helper"

if defined? Site
  describe 'Forum site' do
    dataset :forums, :forum_sites
    # Radiant::Config['reader.layout'] = 'Reader'
    
    it "should have a forums association" do
      Site.reflect_on_association(:forums).should_not be_nil
    end

    it "should have a topics association" do
      Site.reflect_on_association(:topics).should_not be_nil
    end

    it "should have a posts association" do
      Site.reflect_on_association(:posts).should_not be_nil
    end

    it "should have a forum_layout association" do
      Site.reflect_on_association(:forum_layout).should_not be_nil
    end
    
    it "should return reader layout by default" do
      site = sites(:test)
      site.reader_layout = layouts(:reader)
      site.layout_for(:forum).should == 'Reader'
    end

    it "should return forum layout name if specified" do
      site = sites(:test)
      site.reader_layout = layouts(:reader)
      site.forum_layout = layouts(:forum)
      site.layout_for(:forum).should == 'Forum'
    end
  end

end