require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::ForumsController do
  dataset :users
  dataset :forums
  
  it "should be a ResourceController" do
    controller.should be_kind_of(Admin::ResourceController)
  end

  it "should handle Readers" do
    controller.class.model_class.should == Forum
  end

  { 
    :get => [:new, :edit],
    :post => [:create],
    :put => [:update],
    :delete => [:destroy]
  }.each do |method, actions|
    actions.each do |action|
      it "should require login to access the #{action} action" do
        logout
        lambda { send(method, action, :id => forum_id(:public)).should require_login }
      end

      it "should allow you to access to #{action} action if you are an admin" do
        lambda { 
          send(method, action, :id => forum_id(:public)) 
        }.should restrict_access(:allow => users(:admin),
                                 :url => '/admin/page')
      end
      
      it "should deny you access to #{action} action if you are not an admin" do
        lambda { 
          send(method, action, :id => forum_id(:public)) 
        }.should restrict_access(:deny => [users(:developer), users(:existing)],
                                 :url => '/admin/page')
      end
    end
  end
  
  { 
    :get => [:index],
  }.each do |method, actions|
    actions.each do |action|
      it "should allow you to access to #{action} action even if you are not an admin" do
        lambda { 
          send(method, action, :id => forum_id(:public)) 
        }.should restrict_access(:allow => [users(:developer), users(:admin), users(:existing)], :url => '/admin/pages')
      end
    end
  end
end
