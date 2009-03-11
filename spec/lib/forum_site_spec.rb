require File.dirname(__FILE__) + "/../spec_helper"

if defined? Site

  describe 'Forum site' do

    it "should have a forums association" do
      Site.reflect_on_association(:forums).should_not be_nil
    end

    it "should have a topics association" do
      Site.reflect_on_association(:topics).should_not be_nil
    end

    it "should have a posts association" do
      Site.reflect_on_association(:posts).should_not be_nil
    end

  end

end