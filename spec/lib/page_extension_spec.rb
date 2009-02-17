require File.dirname(__FILE__) + "/../spec_helper"

describe 'Forum-extended page' do

  it "should have a topic association" do
    Page.reflect_on_association(:topic).should_not be_nil
  end
 
  it "should create a topic if it doesn't already have one" do

  end

  it "should know whether it has posts or not" do

  end
    
end
