require File.dirname(__FILE__) + '/../spec_helper'

describe ForumsController do
  dataset :forums

  before do
    controller.stub!(:request).and_return(request)
    Radiant::Config['forum.public?'] = true
  end
    
  describe "on get to index" do
    before do
      get :index
    end

    it "should render the forum front page" do
      response.should be_success
      response.should render_template("index")
    end  
  end
    
  describe "on get to show" do
    before do
      @forum = forums(:public)
      get :show, :id => forum_id(:public)
    end
    
    it "should render the forum template" do
      response.should be_success
      response.should render_template("show")
    end
  end
  
  [:new, :edit, :update, :create, :destroy].each do |action|
    it "should fail #{action} requests" do
      lambda { get action, :id => forum_id(:public) }.should raise_error ActionController::RoutingError
    end
  end

end
