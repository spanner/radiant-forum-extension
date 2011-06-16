require File.dirname(__FILE__) + "/../spec_helper"

describe 'Forum reader' do

  it "should have a posts association" do
    Reader.reflect_on_association(:posts).should_not be_nil
  end

end
