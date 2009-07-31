require File.dirname(__FILE__) + '/../spec_helper'
Radiant::Config['reader.layout'] = 'Main'

describe ForumsController do
  dataset :forum_readers
  dataset :forums

  before do
    controller.stub!(:request).and_return(request)
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
    it "should redirect #{action} requests to admin login" do
      get action, :id => forum_id(:public)
      response.should be_redirect
      response.should redirect_to(admin_forums_url)
    end
  end
end
