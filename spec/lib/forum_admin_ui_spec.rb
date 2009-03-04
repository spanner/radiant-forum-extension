require File.dirname(__FILE__) + "/../spec_helper"

describe "AdminUI extensions for forum" do
  before :each do
    @admin = Radiant::AdminUI.new
    @admin.forum = Radiant::AdminUI.load_default_forum_regions
  end

  it "should be included into Radiant::AdminUI" do
    Radiant::AdminUI.included_modules.should include(ForumAdminUI)
  end

  it "should define a collection of Region Sets for forum" do
    @admin.should respond_to('forum')
    @admin.should respond_to('forums')
    @admin.send('forum').should_not be_nil
    @admin.send('forum').should be_kind_of(OpenStruct)
  end

  describe "should define default regions" do
    %w{new edit remove index}.each do |action|
      
      describe "for '#{action}'" do
        before do
          @forum = @admin.forum
          @forum.send(action).should_not be_nil
        end
              
        it "as a RegionSet" do
          @forum.send(action).should be_kind_of(Radiant::AdminUI::RegionSet)
        end
      end
    end
  end
end
